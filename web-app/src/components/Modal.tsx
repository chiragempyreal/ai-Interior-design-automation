import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, CheckCircle, AlertCircle, Info } from 'lucide-react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  message: string;
  type?: 'success' | 'error' | 'info';
  actionLabel?: string;
  onAction?: () => void;
}

const Modal: React.FC<ModalProps> = ({ 
  isOpen, 
  onClose, 
  title, 
  message, 
  type = 'info',
  actionLabel = 'Okay',
  onAction 
}) => {
  const handleAction = () => {
    if (onAction) onAction();
    onClose();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center px-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-charcoal/60 backdrop-blur-sm"
          />

          {/* Modal Content */}
          <motion.div
            initial={{ scale: 0.95, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.95, opacity: 0, y: 20 }}
            transition={{ type: "spring", duration: 0.5, bounce: 0.3 }}
            onClick={(e) => e.stopPropagation()}
            className="relative bg-white rounded-[2rem] shadow-[0_40px_80px_-20px_rgba(43,62,58,0.15)] max-w-md w-full overflow-hidden border border-charcoal/5"
          >
            {/* Background Pattern */}
            <div className="absolute inset-0 architectural-pattern opacity-[0.03] pointer-events-none" />

            {/* Header / Icon */}
            <div className="p-8 pb-2 flex items-start gap-5 relative z-10">
              <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 shadow-sm border ${
                type === 'success' ? 'bg-[#7A9A8C]/10 border-[#7A9A8C]/20 text-[#7A9A8C]' :
                type === 'error' ? 'bg-[#C08080]/10 border-[#C08080]/20 text-[#C08080]' :
                'bg-primary/5 border-primary/10 text-primary'
              }`}>
                {type === 'success' ? <CheckCircle size={26} strokeWidth={1.5} /> :
                 type === 'error' ? <AlertCircle size={26} strokeWidth={1.5} /> :
                 <Info size={26} strokeWidth={1.5} />}
              </div>
              <div className="flex-1 pt-1.5">
                 <h3 className="text-2xl font-display font-bold text-charcoal leading-tight tracking-tight">{title}</h3>
              </div>
              <button 
                onClick={onClose}
                className="text-charcoal/40 hover:text-charcoal transition-colors -mr-2 -mt-2 p-2 rounded-full hover:bg-charcoal/5"
              >
                <X size={20} />
              </button>
            </div>

            {/* Body */}
            <div className="px-8 pb-8 pt-2 relative z-10">
              <p className="text-charcoal/70 font-geist leading-relaxed text-md text-center tracking-wide">
                {message}
              </p>
            </div>

            {/* Footer */}
            <div className="px-8 py-6 bg-charcoal/[0.02] border-t border-charcoal/5 flex justify-end relative z-10">
              <button
                onClick={handleAction}
                className={`px-8 py-3 rounded-full font-geist text-[11px] font-bold tracking-[0.2em] uppercase transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 active:scale-95 ${
                  type === 'success' ? 'bg-[#4A6C5D] hover:bg-[#3D5A4F] text-white shadow-[#4A6C5D]/20' :
                  type === 'error' ? 'bg-[#C08080] hover:bg-[#A66666] text-white shadow-[#C08080]/20' :
                  'bg-primary hover:bg-primary-dark text-white shadow-primary/20'
                }`}
              >
                {actionLabel}
              </button>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};

export default Modal;
