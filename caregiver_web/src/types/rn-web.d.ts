import 'react-native';

/** Bổ sung type cho các prop chỉ có trên React Native Web. */
declare module 'react-native' {
  interface ViewProps {
    /** RN Web: render thành thuộc tính data-* (dùng cho animation CSS). */
    dataSet?: Record<string, string | undefined>;
  }
  interface TextProps {
    dataSet?: Record<string, string | undefined>;
  }
}
