import { useEffect, useState } from 'react';
import {
  Box, Button, Card, CardContent, InputAdornment, MenuItem, Stack, Table, TableBody,
  TableCell, TableContainer, TableHead, TablePagination, TableRow, TableSortLabel,
  TextField, Typography,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import { exportToCSV } from '../../hooks/useTableControls';

const DataTable = ({
  title,
  columns,
  fetchData,
  filterOptions = [],
  onAdd,
  addLabel = 'Add',
  exportFilename = 'export.csv',
  refreshKey = 0,
}) => {
  const [rows, setRows] = useState([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [sortBy, setSortBy] = useState('id');
  const [sortOrder, setSortOrder] = useState('DESC');
  const [filters, setFilters] = useState({});

  const loadData = async () => {
    setLoading(true);
    try {
      const params = {
        search,
        page: page + 1,
        limit: rowsPerPage,
        sortBy,
        sortOrder,
        ...filters,
      };
      const res = await fetchData(params);
      setRows(res.data.data.items || []);
      setTotal(res.data.data.total || 0);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [search, page, rowsPerPage, sortBy, sortOrder, filters, refreshKey]);

  const handleSort = (field) => {
    if (sortBy === field) setSortOrder(sortOrder === 'ASC' ? 'DESC' : 'ASC');
    else { setSortBy(field); setSortOrder('ASC'); }
  };

  return (
    <Card>
      <CardContent>
        <Stack direction={{ xs: 'column', md: 'row' }} justifyContent="space-between" alignItems={{ xs: 'stretch', md: 'center' }} spacing={2} mb={2}>
          <Typography variant="h6" fontWeight={700}>{title}</Typography>
          <Stack direction="row" spacing={1} flexWrap="wrap">
            <TextField
              size="small"
              placeholder="Search..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0); }}
              InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon fontSize="small" /></InputAdornment> }}
              sx={{ minWidth: 200 }}
            />
            {filterOptions.map((f) => (
              <TextField
                key={f.key}
                select
                size="small"
                label={f.label}
                value={filters[f.key] || 'all'}
                onChange={(e) => { setFilters((p) => ({ ...p, [f.key]: e.target.value })); setPage(0); }}
                sx={{ minWidth: 140 }}
              >
                <MenuItem value="all">All</MenuItem>
                {f.options.map((o) => (
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                ))}
              </TextField>
            ))}
            <Button variant="outlined" startIcon={<FileDownloadIcon />} onClick={() => exportToCSV(rows, columns, exportFilename)}>
              Export CSV
            </Button>
            {onAdd && (
              <Button variant="contained" onClick={onAdd}>{addLabel}</Button>
            )}
          </Stack>
        </Stack>

        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                {columns.map((col) => (
                  <TableCell key={col.field || col.label}>
                    {col.sortable !== false && col.field ? (
                      <TableSortLabel
                        active={sortBy === col.field}
                        direction={sortBy === col.field ? sortOrder.toLowerCase() : 'asc'}
                        onClick={() => handleSort(col.field)}
                      >
                        {col.label}
                      </TableSortLabel>
                    ) : col.label}
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={columns.length} align="center">Loading...</TableCell></TableRow>
              ) : rows.length === 0 ? (
                <TableRow><TableCell colSpan={columns.length} align="center">No data found</TableCell></TableRow>
              ) : (
                rows.map((row, idx) => (
                  <TableRow key={row.id || idx} hover>
                    {columns.map((col) => (
                      <TableCell key={col.field || col.label}>
                        {col.render ? col.render(row) : row[col.field]}
                      </TableCell>
                    ))}
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <TablePagination
          component="div"
          count={total}
          page={page}
          onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          rowsPerPageOptions={[5, 10, 25, 50]}
        />
      </CardContent>
    </Card>
  );
};

export default DataTable;
