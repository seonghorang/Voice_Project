from flask import Flask, request
import librosa
import numpy as np
import os
import uuid

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
    files = request.files.getlist('file')
    keys = {}
    for file in files:
        # 고유 이름 생성
        filename = 'temp_{}.wav'.format(uuid.uuid4())
        # 임시 파일로 저장
        file.save(filename)
        try:
            wav_filename = filename.replace('.mp3', '.wav')
            key = calculate_key(wav_filename)
            keys[file.filename] = key
        except Exception as e:
            return {'error': str(e)}
        finally:
            # 임시 파일 삭제
            if os.path.exists(wav_filename):
                try:
                    os.remove(wav_filename)
                except OSError as e:
                    return {'error': 'Failed to delete file {}'.format(wav_filename)}
    return keys

if __name__ == '__main__':
    app.run(debug=True)
