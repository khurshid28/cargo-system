/** Tailwind preset shared across admin dashboards. */
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eef7ff',
          100: '#d9ecff',
          200: '#bcdfff',
          300: '#8ecbff',
          400: '#58aeff',
          500: '#2f8dff',
          600: '#1670f5',
          700: '#1259e0',
          800: '#1549b3',
          900: '#17418d',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
};
