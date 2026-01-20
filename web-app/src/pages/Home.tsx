import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, Sparkles } from 'lucide-react';

const Home: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-4 text-center">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="mb-6 inline-flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 text-blue-600">
          <Sparkles size={32} />
        </div>
        <h1 className="text-4xl font-bold mb-4 text-gray-900">
          AI Interior Design Automation
        </h1>
        <p className="text-xl text-gray-600 mb-8 max-w-2xl">
          Transform your space with our AI-powered design assistant. Get instant quotes and visualization.
        </p>
        <Link
          to="/wizard"
          className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 transition-colors"
        >
          Start Your Project
          <ArrowRight className="ml-2" size={20} />
        </Link>
      </motion.div>
    </div>
  );
};

export default Home;
