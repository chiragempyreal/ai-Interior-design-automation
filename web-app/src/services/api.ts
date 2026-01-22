import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5001/api/v1',
  timeout: 340000, // Increased to 2 minutes for AI generation
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      if (!config.headers) {
        config.headers = new axios.AxiosHeaders();
      }
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      if (error.response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        window.location.href = '/login';
      } else if (error.response.status === 500) {
        window.dispatchEvent(new CustomEvent('api-error', { 
          detail: { 
            title: 'Server Error', 
            message: error.response.data?.message || 'An unexpected server error occurred. Please try again later.' 
          } 
        }));
      }
    }
    return Promise.reject(error);
  }
);

export default api;
