import React, { useState } from 'react';
import { motion } from 'framer-motion';

const Wizard: React.FC = () => {
  const [step, setStep] = useState(1);

  return (
    <div className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-gray-900">Project Setup Wizard</h2>
        <div className="mt-4 bg-gray-200 rounded-full h-2.5 dark:bg-gray-700">
          <div 
            className="bg-blue-600 h-2.5 rounded-full transition-all duration-300" 
            style={{ width: `${(step / 3) * 100}%` }}
          ></div>
        </div>
      </div>

      <motion.div
        key={step}
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -20 }}
        className="bg-white shadow rounded-lg p-6"
      >
        {step === 1 && (
          <div>
            <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">Step 1: Room Details</h3>
            <div className="grid grid-cols-1 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">Room Type</label>
                <select className="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md">
                  <option>Living Room</option>
                  <option>Bedroom</option>
                  <option>Kitchen</option>
                  <option>Office</option>
                </select>
              </div>
            </div>
          </div>
        )}

        {/* Placeholder for other steps */}
        <div className="mt-8 flex justify-between">
          <button
            onClick={() => setStep(s => Math.max(1, s - 1))}
            disabled={step === 1}
            className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
          >
            Previous
          </button>
          <button
            onClick={() => setStep(s => Math.min(3, s + 1))}
            className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
          >
            {step === 3 ? 'Finish' : 'Next'}
          </button>
        </div>
      </motion.div>
    </div>
  );
};

export default Wizard;
