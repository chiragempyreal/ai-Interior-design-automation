import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Login from './pages/Login';
import Wizard from './pages/Wizard';
import HowItWorks from './pages/HowItWorks';
import Pricing from './pages/Pricing';
import Examples from './pages/Examples';
import Profile from './pages/Profile';
import ProtectedRoute from './components/ProtectedRoute';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <div className="min-h-screen bg-background font-sans text-text">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route 
              path="/wizard" 
              element={
                <ProtectedRoute>
                  <Wizard />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/profile" 
              element={
                <ProtectedRoute>
                  <Profile />
                </ProtectedRoute>
              } 
            />
            <Route path="/how-it-works" element={<HowItWorks />} />
            <Route path="/pricing" element={<Pricing />} />
            <Route path="/examples" element={<Examples />} />
          </Routes>
        </div>
      </Router>
    </QueryClientProvider>
  );
}

export default App;
