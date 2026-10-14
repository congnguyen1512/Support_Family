#!/usr/bin/env python3
"""Convert a TensorFlow model to a mobile-safe TFLite model.

This script is intended to reduce runtime incompatibilities on Android/iOS.
It converts from SavedModel/Keras source, because op versions in an existing
.tflite file cannot be reliably downgraded in-place.
"""

from __future__ import annotations

import argparse
import pathlib
import sys
import tempfile

import tensorflow as tf


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert fall detection model to TFLite for mobile runtime",
    )
    parser.add_argument(
        "--source",
        required=True,
        help="Path to SavedModel directory or Keras model file (.keras/.h5)",
    )
    parser.add_argument(
        "--output",
        default="assets/models/fall_multitask_model.tflite",
        help="Output .tflite path",
    )
    parser.add_argument(
        "--allow-select-tf-ops",
        action="store_true",
        help="Allow SELECT_TF_OPS if builtin-only conversion fails",
    )
    parser.add_argument(
        "--float16",
        action="store_true",
        help="Enable float16 weight quantization",
    )
    parser.add_argument(
        "--dynamic-range",
        action="store_true",
        help="Enable dynamic range quantization",
    )
    return parser.parse_args()


def build_converter(
    source: pathlib.Path,
) -> tuple[tf.lite.TFLiteConverter, tempfile.TemporaryDirectory[str] | None]:
    if source.is_dir():
        return tf.lite.TFLiteConverter.from_saved_model(str(source)), None

    suffix = source.suffix.lower()
    if suffix in {".keras", ".h5", ".hdf5"}:
        # More stable than direct from_keras_model for complex graphs.
        # We export a temporary SavedModel and convert from that.
        model = tf.keras.models.load_model(str(source), compile=False)
        temp_dir = tempfile.TemporaryDirectory(prefix="fg_saved_model_")

        export_path = pathlib.Path(temp_dir.name)
        if hasattr(model, "export"):
            model.export(str(export_path))
        else:
            model.save(str(export_path), save_format="tf")

        converter = tf.lite.TFLiteConverter.from_saved_model(str(export_path))
        return converter, temp_dir

    raise ValueError(
        "Unsupported source format. Use SavedModel directory or .keras/.h5 file."
    )


def configure_converter(
    converter: tf.lite.TFLiteConverter,
    allow_select_tf_ops: bool,
    float16: bool,
    dynamic_range: bool,
) -> None:
    converter.experimental_new_converter = True

    if allow_select_tf_ops:
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS,
        ]
    else:
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]

    if float16:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
    elif dynamic_range:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]



def verify_model(model_bytes: bytes) -> None:
    interpreter = tf.lite.Interpreter(model_content=model_bytes)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print("[OK] Interpreter created successfully")
    print(f"[INFO] Inputs: {[d['shape'].tolist() for d in input_details]}")
    print(f"[INFO] Outputs: {[d['shape'].tolist() for d in output_details]}")



def main() -> int:
    args = parse_args()
    source = pathlib.Path(args.source).expanduser().resolve()
    output = pathlib.Path(args.output).expanduser().resolve()

    if not source.exists():
        print(f"[ERROR] Source path does not exist: {source}")
        return 1

    output.parent.mkdir(parents=True, exist_ok=True)

    try:
        converter, temp_dir = build_converter(source)
        configure_converter(
            converter,
            allow_select_tf_ops=args.allow_select_tf_ops,
            float16=args.float16,
            dynamic_range=args.dynamic_range,
        )

        print(f"[INFO] Converting from: {source}")
        print(f"[INFO] Output path: {output}")
        print(
            "[INFO] supported_ops="
            + (
                "TFLITE_BUILTINS+SELECT_TF_OPS"
                if args.allow_select_tf_ops
                else "TFLITE_BUILTINS"
            )
        )

        tflite_model = converter.convert()
        verify_model(tflite_model)
        output.write_bytes(tflite_model)

        if temp_dir is not None:
            temp_dir.cleanup()

        print(f"[DONE] Wrote: {output}")
        print(
            "[NEXT] Run: flutter clean && flutter pub get && flutter run"
        )
        return 0

    except Exception as error:  # pragma: no cover
        print(f"[ERROR] Conversion failed: {error}")
        print(
            "[HINT] If builtin-only failed, retry with --allow-select-tf-ops."
        )
        return 1


if __name__ == "__main__":
    sys.exit(main())
