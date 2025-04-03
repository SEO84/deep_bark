import torch
import torch.nn as nn


import torchvision.models as models
# 모델 로드 함수 (ResNet50 기반 전이 학습 모델)
def load_model(model_path="model/Dogs_classifier_model.pth"):
    model = models.resnet50(pretrained=False)
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, 62)
    model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
    model.eval()
    return model