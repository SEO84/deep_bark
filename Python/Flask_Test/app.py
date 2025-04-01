import os
import torch
from flask import Flask, request, jsonify, render_template, url_for, send_from_directory, send_file
from flask_cors import CORS
import threading
import cv2
from ultralytics import YOLO
import re
import eventlet.wsgi

# ✅ Flask 앱 초기화
app = Flask(__name__)
CORS(app)  # CORS 허용

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# ✅ YOLO 모델 로드
# yolo_model = YOLO("model/best-busanit501-aqua.pt")
yolo_model = YOLO("model/생성된 모델")
# app.config['SERVER_NAME'] = '10.100.201.87:5000'  # Flask 서버 주소와 포트 설정

# ✅ 결과 저장 폴더 설정
UPLOAD_FOLDER = 'uploads'
RESULT_FOLDER = 'results'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)

processing_status = {}

# 🔹 2️⃣ YOLO 비동기 처리 함수
def process_yolo(file_path, output_path, file_type):
    """YOLO 모델을 비동기적으로 실행"""
    try:
        print(f"✅ [INFO] YOLO 처리 시작 - {file_path}")

        if file_type == 'image':
            results = yolo_model(file_path)
            result_img = results[0].plot()
            cv2.imwrite(output_path, result_img)

        elif file_type == 'video':
            cap = cv2.VideoCapture(file_path)
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = int(cap.get(cv2.CAP_PROP_FPS))

            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                results = yolo_model(frame)
                result_frame = results[0].plot()
                out.write(result_frame)

            cap.release()
            out.release()

        print(f"✅ [INFO] YOLO 처리 완료 - {output_path}")

    except Exception as e:
        print(f"❌ [ERROR] YOLO 처리 중 오류 발생: {str(e)}")

@app.route('/download/<filename>')
def download_file(filename):
    file_path = os.path.join(RESULT_FOLDER, filename)
    if not os.path.isfile(file_path):
        return jsonify({"error": "File not found"}), 404
    return send_file(file_path, as_attachment=True, download_name=filename)



# 🔹 1️⃣ 파일 업로드 API (POST 요청)
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "파일이 업로드되지 않았습니다."}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({"error": "파일이 선택되지 않았습니다."}), 400

    filename = file.filename
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    output_filename = f"result_{filename}"
    # 결과 파일은 RESULT_FOLDER에 저장됩니다.
    output_path = os.path.join(RESULT_FOLDER, output_filename)

    print("filename : " + filename)
    # 업로드된 파일의 확장자를 확인하여 이미지(image)인지 비디오(video)인지 판별합니다.
    if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp')):
        file_type = 'image'
    elif filename.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
        file_type = 'video'
    else:
        # 지원하지 않는 파일 형식일 경우 400 에러를 반환합니다.
        return jsonify({"error": "Unsupported file type"}), 400

    request_id = filename.split(".")[0]  # 파일명을 요청 ID로 사용

    # YOLO 비동기 처리
    thread = threading.Thread(target=process_yolo, args=(file_path, output_path, file_type, request_id))
    thread.start()

    # ✅ 업로드 성공 응답
    return jsonify({
        "message": "파일 업로드 성공",
        "filename": filename,
        "file_url": url_for('uploaded_file', filename=filename, _external=True)
    }), 200


# 🔹 2️⃣ 업로드된 파일 제공 API
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)



# 🔹 1️⃣ 기본 Index 화면 (파일 업로드 UI)
@app.route("/")
def index():
    return render_template('index.html')

# 🔹 4️⃣ 이미지 분류 API (POST 요청)
@app.route("/predict/<model_type>", methods=["POST"])
def predict(model_type):
    if "image" not in request.files:
        return jsonify({"error": "이미지가 업로드되지 않았습니다."}), 400

    file = request.files["image"]

    if file.filename == "":
        return jsonify({"error": "파일이 선택되지 않았습니다."}), 400

    filename = file.filename
    sanitized_filename = re.sub(r"[^\w.-]", "_", filename)  # 공백 및 특수문자를 _로 변경

    # ✅ YOLOv8 처리 분기
    if model_type == "yolo":
        file_path = os.path.join(UPLOAD_FOLDER, sanitized_filename)
        file.save(file_path)

        output_filename = f"result_{sanitized_filename}"
        output_path = os.path.join(RESULT_FOLDER, output_filename)

        print(f"YOLO 처리 시작 predict_yolo , filename : {filename}")

        # 파일 유형 확인
        if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp')):
            file_type = 'image'
        elif filename.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
            file_type = 'video'
        else:
            return jsonify({"error": "지원되지 않는 파일 형식입니다."}), 400

            # ✅ YOLO 비동기 처리 (스레드 실행 후 join)
        thread = threading.Thread(target=process_yolo, args=(file_path, output_path, file_type))
        thread.start()
        thread.join()  # ✅ YOLO 처리 완료될 때까지 대기

        # ✅ JSON 응답으로 이미지/동영상 링크 전달
        return jsonify({
            "message": "YOLO 모델이 파일을 처리 중입니다.",
            "file_url": url_for('serve_result', filename=os.path.basename(output_path), _external=True),
            "download_url": url_for('download_file', filename=os.path.basename(output_path), _external=True),
            "file_type": file_type,
        })



# 🔹 5️⃣ 결과 파일 제공 API
@app.route('/results/<filename>')
def serve_result(filename):
    """결과 파일 제공"""
    file_path = os.path.join(RESULT_FOLDER, filename)

    # ✅ 파일이 존재하는지 확인
    if not os.path.exists(file_path):
        return jsonify({"error": f"파일 '{filename}' 이 존재하지 않습니다."}), 404

    print(f"📢 결과 파일 제공: {file_path}")  # 로그 출력
    return send_from_directory(RESULT_FOLDER, filename)


# ✅ Flask 실행
if __name__ == "__main__":
    eventlet.wsgi.server(eventlet.listen(("0.0.0.0", 5000)), app)