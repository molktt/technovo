import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const ProtectedRoute = ({ children, roles }) => {
  const { user, isAuthenticated } = useAuth();

  if (!isAuthenticated) return <Navigate to="/login" replace />;

  const role = (user?.role || '').toString().trim().toUpperCase();

  const redirect = {
    LEADER: '/leader/dashboard',
    ADMIN: '/admin/dashboard',
    HOST: '/host/dashboard',
  };

  if (roles && !roles.includes(role)) {
    return <Navigate to={redirect[role] || '/login'} replace />;
  }

  return children;
};

export default ProtectedRoute;