import { Navigate, Route, Routes } from 'react-router-dom'
import { ProtectedRoute } from './components/ProtectedRoute'
import { AdminLayout } from './layout/AdminLayout'
import { LoginPage } from './pages/LoginPage'
import { OverviewPage } from './pages/OverviewPage'
import { VerificationPage } from './pages/VerificationPage'
import { WalletsPage } from './pages/WalletsPage'
import { CommissionSettingsPage } from './pages/CommissionSettingsPage'
import { OrdersPage } from './pages/OrdersPage'
import { VoiceOrdersPage } from './pages/VoiceOrdersPage'
import { UsersPage } from './pages/UsersPage'
import { RatingsPage } from './pages/RatingsPage'
import { SettingsPage } from './pages/SettingsPage'

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/overview" element={<OverviewPage />} />
        <Route path="/verification" element={<VerificationPage />} />
        <Route path="/wallets" element={<WalletsPage />} />
        <Route path="/wallets/settings" element={<CommissionSettingsPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/voice-orders" element={<VoiceOrdersPage />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/ratings" element={<RatingsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="*" element={<Navigate to="/overview" replace />} />
      </Route>
      <Route path="*" element={<Navigate to="/overview" replace />} />
    </Routes>
  )
}

export default App
