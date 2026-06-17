import { useState, useEffect } from 'react';
import { IconButton } from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { toast } from 'react-toastify';
import DataTable from '../../components/common/DataTable';
import UserModal from '../../components/modals/UserModal';
import { userAPI } from '../../services';

const UsersPage = () => {
  const [modalOpen, setModalOpen] = useState(false);
  const [editData, setEditData] = useState(null);
  const [refreshKey, setRefreshKey] = useState(0);

  const columns = [
    { field: 'name', label: 'Name' },
    { field: 'email', label: 'Email' },
    { field: 'role', label: 'Role' },
    { field: 'is_active', label: 'Active', render: (r) => (r.is_active ? 'Yes' : 'No') },
    {
      label: 'Actions',
      sortable: false,
      render: (row) => (
        <>
          <IconButton size="small" onClick={() => { setEditData(row); setModalOpen(true); }}><EditIcon fontSize="small" /></IconButton>
          <IconButton size="small" color="error" onClick={async () => {
            if (window.confirm('Delete this user?')) {
              await userAPI.delete(row.id);
              toast.success('User deleted successfully');
              setRefreshKey((k) => k + 1);
            }
          }}><DeleteIcon fontSize="small" /></IconButton>
        </>
      ),
    },
  ];

  const handleSave = async (data) => {
    try {
      const payload = { ...data, is_active: Number(data.is_active) };
      if (editData) {
        await userAPI.update(editData.id, payload);
        toast.success('User updated successfully');
      } else {
        await userAPI.create(payload);
        toast.success('User created successfully');
      }
      setModalOpen(false);
      setEditData(null);
      setRefreshKey((k) => k + 1);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to save user');
    }
  };

  return (
    <>
      <DataTable title="Users" columns={columns} fetchData={userAPI.getAll}
        filterOptions={[{ key: 'role', label: 'Role', options: [{ value: 'LEADER', label: 'Leader' }, { value: 'ADMIN', label: 'Admin' }, { value: 'HOST', label: 'Host' }] }]}
        onAdd={() => { setEditData(null); setModalOpen(true); }} addLabel="Add User" exportFilename="users.csv" refreshKey={refreshKey} />
      <UserModal open={modalOpen} onClose={() => { setModalOpen(false); setEditData(null); }} onSave={handleSave} editData={editData} />
    </>
  );
};

export default UsersPage;
