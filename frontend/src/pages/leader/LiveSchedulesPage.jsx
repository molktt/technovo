import { useState, useEffect } from 'react';
import { IconButton } from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { toast } from 'react-toastify';
import DataTable from '../../components/common/DataTable';
import ScheduleModal from '../../components/modals/ScheduleModal';
import { masterAPI, scheduleAPI } from '../../services';

const LiveSchedulesPage = () => {
  const [modalOpen, setModalOpen] = useState(false);
  const [editData, setEditData] = useState(null);
  const [hosts, setHosts] = useState([]);
  const [platforms, setPlatforms] = useState([]);
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    masterAPI.getAll().then((res) => {
      setHosts(res.data.data.hosts);
      setPlatforms(res.data.data.platforms);
    }).catch(console.error);
  }, []);

  const columns = [
    { field: 'title', label: 'Title' },
    { field: 'host_name', label: 'Host' },
    { field: 'platform_name', label: 'Platform' },
    { field: 'schedule_date', label: 'Date' },
    { field: 'start_time', label: 'Start' },
    { field: 'end_time', label: 'End' },
    { field: 'status', label: 'Status' },
    {
      label: 'Actions', sortable: false,
      render: (row) => (
        <>
          <IconButton size="small" onClick={() => { setEditData(row); setModalOpen(true); }}><EditIcon fontSize="small" /></IconButton>
          <IconButton size="small" color="error" onClick={async () => {
            if (window.confirm('Delete schedule?')) {
              await scheduleAPI.delete(row.id);
              toast.success('Schedule deleted successfully');
              setRefreshKey((k) => k + 1);
            }
          }}><DeleteIcon fontSize="small" /></IconButton>
        </>
      ),
    },
  ];

  const handleSave = async (data) => {
    try {
      const payload = { ...data, host_id: Number(data.host_id), platform_id: Number(data.platform_id) };
      if (editData) {
        await scheduleAPI.update(editData.id, payload);
        toast.success('Schedule updated successfully');
      } else {
        await scheduleAPI.create(payload);
        toast.success('Schedule created successfully');
      }
      setModalOpen(false);
      setEditData(null);
      setRefreshKey((k) => k + 1);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to save schedule');
    }
  };

  return (
    <>
      <DataTable title="Live Schedules" columns={columns} fetchData={scheduleAPI.getAll}
        filterOptions={[
          { key: 'platform_id', label: 'Platform', options: platforms.map((p) => ({ value: p.id, label: p.name })) },
          { key: 'status', label: 'Status', options: [{ value: 'scheduled', label: 'Scheduled' }, { value: 'completed', label: 'Completed' }, { value: 'cancelled', label: 'Cancelled' }] },
        ]}
        onAdd={() => { setEditData(null); setModalOpen(true); }} addLabel="Add Schedule" exportFilename="schedules.csv" refreshKey={refreshKey} />
      <ScheduleModal open={modalOpen} onClose={() => { setModalOpen(false); setEditData(null); }} onSave={handleSave} editData={editData} hosts={hosts} platforms={platforms} />
    </>
  );
};

export default LiveSchedulesPage;
