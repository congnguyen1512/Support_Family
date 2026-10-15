import React, { Suspense, lazy } from 'react';
import { View } from 'react-native';
import type { FamilyMapProps } from './FamilyMap';
import { Loader } from '../ui';

const FamilyMap = lazy(() => import('./FamilyMap'));

/** Bản đồ tải lười (Leaflet chỉ được tải khi cần) để trang đầu mở nhanh hơn. */
export function LazyFamilyMap(props: FamilyMapProps) {
  return (
    <Suspense
      fallback={
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <Loader label="Đang tải bản đồ..." />
        </View>
      }
    >
      <FamilyMap {...props} />
    </Suspense>
  );
}

export { presenceColor, DEFAULT_CENTER } from './presence';
