/** @type {import('tailwindcss').Config} */
import preset from '@cargos/ui-kit/tailwind-preset';

export default {
  presets: [preset],
  content: ['./index.html', './src/**/*.{ts,tsx}', '../../packages/ui-kit/src/**/*.{ts,tsx}'],
  plugins: [],
};
