import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, CheckCircle, AlertCircle, Info } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info';

export interface ToastMessage {
  id: string;
  message: string;
  type: ToastType;
}

interface ToastProps {
  toasts: ToastMessage[];
  removeToast: (id: string) => void;
}

const ToastContainer: React.FC<ToastProps> = ({ toasts, removeToast }) => {
  return (
    <div className="fixed top-4 right-4 z-[200] flex flex-col gap-3 pointer-events-none">
      <AnimatePresence mode="popLayout">
        {toasts.map((toast) => (
          <ToastItem key={toast.id} toast={toast} removeToast={removeToast} />
        ))}
      </AnimatePresence>
    </div>
  );
};

const ToastItem: React.FC<{ toast: ToastMessage; removeToast: (id: string) => void }> = ({ toast, removeToast }) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      removeToast(toast.id);
    }, 5000); // Auto dismiss after 5 seconds

    return () => clearTimeout(timer);
  }, [toast.id, removeToast]);

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: 50, scale: 0.9 }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, x: 20, scale: 0.9 }}
      transition={{ type: "spring", stiffness: 400, damping: 25 }}
      className="pointer-events-auto min-w-[320px] max-w-md bg-white rounded-xl shadow-[0_8px_30px_rgba(0,0,0,0.12)] border border-border/50 overflow-hidden flex items-start gap-3 p-4 pr-10 relative backdrop-blur-sm"
    >
      <div className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
        toast.type === 'success' ? 'bg-success/10 text-success' :
        toast.type === 'error' ? 'bg-error/10 text-error' :
        'bg-primary/10 text-primary'
      }`}>
        {toast.type === 'success' ? <CheckCircle size={16} /> :
         toast.type === 'error' ? <AlertCircle size={16} /> :
         <Info size={16} />}
      </div>
      
      <div className="flex-1 pt-1">
        <p className="text-sm font-medium text-text leading-tight">{toast.message}</p>
      </div>

      <button 
        onClick={() => removeToast(toast.id)}
        className="absolute top-4 right-4 text-text-secondary hover:text-text transition-colors"
      >
        <X size={16} />
      </button>
      
      {/* Progress Bar (Optional aesthetic touch) */}
      <motion.div 
        initial={{ width: "100%" }}
        animate={{ width: "0%" }}
        transition={{ duration: 5, ease: "linear" }}
        className={`absolute bottom-0 left-0 h-0.5 ${
          toast.type === 'success' ? 'bg-success/30' :
          toast.type === 'error' ? 'bg-error/30' :
          'bg-primary/30'
        }`}
      />
    </motion.div>
  );
};

export default ToastContainer;
