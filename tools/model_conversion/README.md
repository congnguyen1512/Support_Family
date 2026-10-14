Model Conversion For Mobile Runtime

Why:
- Existing fall model fails on device with:
  Didn't find op for builtin opcode 'FULLY_CONNECTED' version '12'
- This means the TFLite runtime in app is older than the model op versions.

Important:
- You should convert from original source model (SavedModel or Keras).
- Do not try to downgrade op versions directly from an existing .tflite file.

Setup:
1. python3 -m venv .venv
2. source .venv/bin/activate
3. pip install -r tools/model_conversion/requirements.txt

Builtin-only conversion (preferred):
python tools/model_conversion/convert_fall_model.py \
  --source /path/to/saved_model_or_keras \
  --output assets/models/fall_multitask_model.tflite

Fallback with SELECT_TF_OPS:
python tools/model_conversion/convert_fall_model.py \
  --source /path/to/saved_model_or_keras \
  --output assets/models/fall_multitask_model.tflite \
  --allow-select-tf-ops

After replacing model:
1. flutter clean
2. flutter pub get
3. flutter run
