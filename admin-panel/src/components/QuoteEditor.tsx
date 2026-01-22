import React, { useState, useEffect } from 'react';
import { Plus, Trash2, Save, Send, FileText, Eye } from 'lucide-react';
import api from '@/services/api';
import { useMutation } from '@tanstack/react-query';
import { useToast } from '@/context/ToastContext';
import Modal from './Modal';

interface QuoteItem {
  name: string;
  category: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

interface Quote {
  _id: string;
  totalAmount: number;
  items: QuoteItem[];
  pdfUrl?: string;
  status: string;
  version: number;
}

interface QuoteEditorProps {
  quote: Quote;
  onUpdate: () => void;
}

const QuoteEditor: React.FC<QuoteEditorProps> = ({ quote, onUpdate }) => {
  const { success, error } = useToast();
  const [items, setItems] = useState<QuoteItem[]>(quote.items);
  const [saving, setSaving] = useState(false);
  const [finalizing, setFinalizing] = useState(false);
  const [previewing, setPreviewing] = useState(false);
  const [itemsChanged, setItemsChanged] = useState(false);

  const [modalConfig, setModalConfig] = useState<{
    isOpen: boolean;
    title: string;
    message: string;
    type: 'info' | 'warning' | 'error' | 'success';
    actionLabel: string;
    onAction: () => void;
    secondaryActionLabel?: string;
    onSecondaryAction?: () => void;
  }>({
    isOpen: false,
    title: '',
    message: '',
    type: 'info',
    actionLabel: 'Okay',
    onAction: () => {},
  });

  const closeModal = () => {
    setModalConfig(prev => ({ ...prev, isOpen: false }));
  };

  useEffect(() => {
    setItems(quote.items);
    setItemsChanged(false);
  }, [quote]);

  const handleItemChange = (index: number, field: keyof QuoteItem, value: string | number) => {
    const newItems = [...items];
    const item = { ...newItems[index] };

    if (field === 'quantity' || field === 'unitPrice') {
      const numValue = Number(value);
      if (field === 'quantity') item.quantity = numValue;
      if (field === 'unitPrice') item.unitPrice = numValue;
      item.totalPrice = item.quantity * item.unitPrice;
    } else if (field === 'name' || field === 'category') {
      item[field] = value as string;
    }

    newItems[index] = item;
    setItems(newItems);
    setItemsChanged(true);
  };

  const addItem = () => {
    setItems([
      ...items,
      { name: '', category: 'Material', quantity: 1, unitPrice: 0, totalPrice: 0 }
    ]);
    setItemsChanged(true);
  };

  const removeItem = (index: number) => {
    const newItems = items.filter((_, i) => i !== index);
    setItems(newItems);
    setItemsChanged(true);
  };

  const calculateTotal = () => {
    return items.reduce((sum, item) => sum + item.totalPrice, 0);
  };

  const saveQuoteMutation = useMutation({
    mutationFn: async (updatedItems: QuoteItem[]) => {
      await api.put(`/admin/quotes/${quote._id}`, { items: updatedItems });
    },
    onSuccess: () => {
      setItemsChanged(false);
      onUpdate();
      success('Quote updated successfully');
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      error(err.response?.data?.message || 'Failed to update quote');
    }
  });

  const previewQuoteMutation = useMutation({
    mutationFn: async () => {
      const response = await api.post(`/admin/quotes/${quote._id}/preview`);
      return response.data.data.pdfUrl;
    },
    onSuccess: (pdfUrl) => {
      onUpdate();
      success('Preview generated successfully');
      // Open PDF in new tab
      if (pdfUrl) {
         const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000';
         let baseUrl = apiUrl;
         try {
           baseUrl = new URL(apiUrl).origin;
         } catch (e) {
           console.error('Invalid API URL', e);
         }

         const fullUrl = pdfUrl.startsWith('http') ? pdfUrl : `${baseUrl}${pdfUrl}`;
         window.open(fullUrl, '_blank');
      }
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      error(err.response?.data?.message || 'Failed to generate preview');
    }
  });

  const finalizeQuoteMutation = useMutation({
    mutationFn: async () => {
      await api.post(`/admin/quotes/${quote._id}/finalize`);
    },
    onSuccess: () => {
      onUpdate();
      success('Quote finalized and email sent to client!');
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      error(err.response?.data?.message || 'Failed to finalize quote');
    }
  });

  const handleSave = async () => {
    setSaving(true);
    try {
      await saveQuoteMutation.mutateAsync(items);
    } finally {
      setSaving(false);
    }
  };

  const performPreview = async () => {
    setPreviewing(true);
    try {
      await previewQuoteMutation.mutateAsync();
    } finally {
      setPreviewing(false);
    }
  };

  const handlePreview = async () => {
    if (itemsChanged) {
        setModalConfig({
          isOpen: true,
          title: 'Unsaved Changes',
          message: 'You have unsaved changes. Save and preview?',
          type: 'warning',
          actionLabel: 'Save & Preview',
          onAction: async () => {
            await handleSave();
            closeModal(); // Close first modal
            performPreview();
          },
          secondaryActionLabel: 'Cancel',
          onSecondaryAction: closeModal
        });
        return;
    }
    performPreview();
  };

  const performFinalize = async () => {
    setFinalizing(true);
    try {
      await finalizeQuoteMutation.mutateAsync();
    } finally {
      setFinalizing(false);
    }
  };

  const showFinalizeConfirmation = () => {
    setModalConfig({
      isOpen: true,
      title: 'Send Quote',
      message: 'This will email the PDF to the client. Have you previewed the latest changes?',
      type: 'info',
      actionLabel: 'Send Email',
      onAction: performFinalize,
      secondaryActionLabel: 'Cancel',
      onSecondaryAction: closeModal
    });
  };

  const handleFinalize = async () => {
    if (itemsChanged) {
      setModalConfig({
        isOpen: true,
        title: 'Unsaved Changes',
        message: 'You have unsaved changes. Save and send?',
        type: 'warning',
        actionLabel: 'Save & Send',
        onAction: async () => {
          await handleSave();
          closeModal();
          showFinalizeConfirmation();
        },
        secondaryActionLabel: 'Cancel',
        onSecondaryAction: closeModal
      });
      return;
    }
    
    showFinalizeConfirmation();
  };

  return (
    <div className="bg-surface rounded-xl shadow-sm border border-border overflow-hidden">
      <Modal
        isOpen={modalConfig.isOpen}
        onClose={closeModal}
        title={modalConfig.title}
        message={modalConfig.message}
        type={modalConfig.type}
        actionLabel={modalConfig.actionLabel}
        onAction={modalConfig.onAction}
        secondaryActionLabel={modalConfig.secondaryActionLabel}
        onSecondaryAction={modalConfig.onSecondaryAction}
      />
      <div className="p-6 border-b border-border flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-xl font-bold font-display text-text flex items-center gap-2">
            <FileText className="w-5 h-5 text-primary" />
            Quote Editor
          </h2>
          <p className="text-sm text-text-secondary">
            Version: {quote.version} | Status: <span className="font-medium uppercase">{quote.status}</span>
          </p>
        </div>
        
        <div className="flex gap-2">
          {itemsChanged && (
            <button
              onClick={handleSave}
              disabled={saving}
              className="flex items-center px-4 py-2 bg-text text-white rounded-lg text-sm font-medium hover:bg-text/90 transition-colors disabled:opacity-50"
            >
              <Save className="w-4 h-4 mr-2" />
              {saving ? 'Saving...' : 'Save Changes'}
            </button>
          )}
          
          <button
            onClick={handlePreview}
            disabled={previewing || saving}
            className="flex items-center px-4 py-2 bg-white border border-border text-text rounded-lg text-sm font-medium hover:bg-background-light transition-colors disabled:opacity-50"
          >
            <Eye className="w-4 h-4 mr-2" />
            {previewing ? 'Generating...' : 'Preview PDF'}
          </button>

          <button
            onClick={handleFinalize}
            disabled={finalizing || saving}
            className="flex items-center px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark transition-colors disabled:opacity-50 shadow-lg shadow-primary/25"
          >
            <Send className="w-4 h-4 mr-2" />
            {finalizing ? 'Sending...' : 'Send to Client'}
          </button>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-background-light border-b border-border text-xs uppercase text-text-secondary font-semibold tracking-wider">
              <th className="px-6 py-4">Item Name</th>
              <th className="px-6 py-4">Category</th>
              <th className="px-6 py-4 w-32 text-right">Qty</th>
              <th className="px-6 py-4 w-40 text-right">Unit Price</th>
              <th className="px-6 py-4 w-40 text-right">Total</th>
              <th className="px-6 py-4 w-16"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {items.map((item, index) => (
              <tr key={index} className="hover:bg-background-light/50 transition-colors">
                <td className="px-6 py-3">
                  <input
                    type="text"
                    value={item.name}
                    onChange={(e) => handleItemChange(index, 'name', e.target.value)}
                    className="w-full bg-transparent border-none focus:ring-0 p-0 text-text font-medium placeholder-text-secondary/50"
                    placeholder="Item Name"
                  />
                </td>
                <td className="px-6 py-3">
                  <input
                    type="text"
                    value={item.category}
                    onChange={(e) => handleItemChange(index, 'category', e.target.value)}
                    className="w-full bg-transparent border-none focus:ring-0 p-0 text-text-secondary"
                    placeholder="Category"
                  />
                </td>
                <td className="px-6 py-3 text-right">
                  <input
                    type="number"
                    min="1"
                    value={item.quantity}
                    onChange={(e) => handleItemChange(index, 'quantity', e.target.value)}
                    className="w-full bg-transparent border-none focus:ring-0 p-0 text-right text-text"
                  />
                </td>
                <td className="px-6 py-3 text-right">
                  <div className="flex justify-end items-center gap-1">
                    <span className="text-text-secondary">₹</span>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={item.unitPrice}
                      onChange={(e) => handleItemChange(index, 'unitPrice', e.target.value)}
                      className="w-24 bg-transparent border-none focus:ring-0 p-0 text-right text-text"
                    />
                  </div>
                </td>
                <td className="px-6 py-3 text-right font-medium text-text">
                  ₹{item.totalPrice.toLocaleString('en-IN')}
                </td>
                <td className="px-6 py-3 text-center">
                  <button
                    onClick={() => removeItem(index)}
                    className="p-1 text-text-secondary hover:text-error transition-colors rounded-md hover:bg-error/10"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td colSpan={6} className="px-6 py-8 text-center text-text-secondary italic">
                  No items in quote. Add some items to get started.
                </td>
              </tr>
            )}
          </tbody>
          <tfoot className="bg-background-light border-t border-border font-bold text-text">
            <tr>
              <td colSpan={2} className="px-6 py-4">
                <button
                  onClick={addItem}
                  className="flex items-center text-primary hover:text-primary-dark transition-colors text-sm font-medium"
                >
                  <Plus className="w-4 h-4 mr-1" />
                  Add New Item
                </button>
              </td>
              <td colSpan={2} className="px-6 py-4 text-right uppercase text-xs tracking-wider text-text-secondary">
                Total Estimated Cost:
              </td>
              <td className="px-6 py-4 text-right text-lg text-primary">
                ₹{calculateTotal().toLocaleString('en-IN')}
              </td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
};

export default QuoteEditor;
