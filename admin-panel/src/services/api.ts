import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5001/api/v1',
  timeout: 120000, // Increased to 2 minutes for long-running operations
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response) {
      if (error.response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        if (window.location.pathname !== '/login') {
          window.location.href = '/login';
        }
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
