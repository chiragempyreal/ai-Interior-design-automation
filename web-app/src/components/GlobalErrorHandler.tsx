import React, { useEffect, useState } from 'react';
import Modal from './Modal';

interface ErrorState {
  title: string;
  message: string;
}

const GlobalErrorHandler: React.FC = () => {
  const [error, setError] = useState<ErrorState | null>(null);

  useEffect(() => {
    const handleApiError = (event: Event) => {
      const customEvent = event as CustomEvent<{ message: string; title?: string }>;
      setError({
        title: customEvent.detail.title || 'System Error',
        message: customEvent.detail.message || 'An unexpected error occurred.',
      });
    };

    window.addEventListener('api-error', handleApiError);

    return () => {
      window.removeEventListener('api-error', handleApiError);
    };
  }, []);

  return (
    <Modal
      isOpen={!!error}
      onClose={() => setError(null)}
      title={error?.title || 'Error'}
      message={error?.message || ''}
      type="error"
      actionLabel="Close"
    />
  );
};

export default GlobalErrorHandler;
