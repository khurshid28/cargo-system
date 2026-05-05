import 'leaflet/dist/leaflet.css';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { Card } from '@cargos/ui-kit';

/** Tashkent center as default. Plug in real driver positions via Socket.IO. */
const TASHKENT: [number, number] = [41.3111, 69.2797];

export function TrackingMapPage() {
  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Live Tracking</h1>
      <Card>
        <div className="h-[600px] w-full overflow-hidden rounded-lg">
          <MapContainer center={TASHKENT} zoom={11} style={{ height: '100%', width: '100%' }}>
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <Marker position={TASHKENT}>
              <Popup>Tashkent — markaz</Popup>
            </Marker>
          </MapContainer>
        </div>
      </Card>
    </div>
  );
}
