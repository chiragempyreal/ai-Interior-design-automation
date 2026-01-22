import React, { useEffect, useState } from 'react';
import Modal from './Modal';

interface ErrorState {
  title: string;
  message: string;
  type?: 'error' | 'success' | 'info' | 'warning';
}

const GlobalErrorHandler: React.FC = () => {
  const [error, setError] = useState<ErrorState | null>(null);

  useEffect(() => {
    const handleApiError = (event: Event) => {
      const customEvent = event as CustomEvent<{ message: string; title?: string; type?: 'error' | 'success' | 'info' | 'warning' }>;
      setError({
        title: customEvent.detail.title || 'System Error',
        message: customEvent.detail.message || 'An unexpected error occurred.',
        type: customEvent.detail.type || 'error',
      });
    };

    const handleApiSuccess = (event: Event) => {
      const customEvent = event as CustomEvent<{ message: string; title?: string }>;
      setError({
        title: customEvent.detail.title || 'Success',
        message: customEvent.detail.message || 'Operation completed successfully.',
        type: 'success',
      });
    };

    window.addEventListener('api-error', handleApiError);
    window.addEventListener('api-success', handleApiSuccess);

    return () => {
      window.removeEventListener('api-error', handleApiError);
      window.removeEventListener('api-success', handleApiSuccess);
    };
  }, []);

  return (
    <Modal
      isOpen={!!error}
      onClose={() => setError(null)}
      title={error?.title || 'Notification'}
      message={error?.message || ''}
      type={error?.type || 'info'}
      actionLabel="Close"
    />
  );
};

export default GlobalErrorHandler;
