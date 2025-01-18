import { defineConfig } from 'vite'
import reactRefresh from '@vitejs/plugin-react-refresh'

export default defineConfig({
  logLevel: 'info',
  plugins: [reactRefresh()],
  server: {
    host: process.env.VITE_HOST || '0.0.0.0',
    port: process.env.VITE_PORT || 5173,
    hmr: {
      clientPort: process.env.VITE_CLIENT_PORT || null
    },
    proxy: {
      '^/api': {
        target: process.env.VITE_BACKEND_URL || 'http://backend-service:5000',
        changeOrigin: true
      }
    }
  }
})
