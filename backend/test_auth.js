const auth = require('./src/middleware/auth');
const result = auth.authorize('leader');
console.log('authorize("leader") type:', typeof result);
if (typeof result === 'function') {
  console.log('It is a function');
  console.log('Function toString:', result.toString().substring(0, 100));
} else {
  console.log('Keys:', Object.keys(result));
}
