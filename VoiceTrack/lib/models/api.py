from flask import Flask, request
import librosa
import numpy as np

app = Flask(__name__)

def calculate_key(file_path):
    # 오디오 파일 로드
    y, sr = librosa.load(file_path)
    # chroma feature 추출
    chroma = librosa.feature.chroma_cqt(y=y, sr=sr)
    # 각 chroma에 대한 평균 계산
    chroma_avg = np.mean(chroma, axis=1)
    # 가장 높은 값을 가진 chroma 찾기
    key_idx = np.argmax(chroma_avg)
    # chroma를 음계로 변환
    notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    key = notes[key_idx]
    return key

@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files['file']
    # 임시 파일로 저장
    file.save('temp.wav')
    # 이 파일을 처리하고 결과를 반환합니다.
    key = calculate_key('temp.wav')
    return {'key': key}

if __name__ == '__main__':
    app.run(debug=True)
