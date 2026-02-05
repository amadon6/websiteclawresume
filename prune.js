const fs = require('fs');
const path = 'sessions.json';
let data;
try {
  data = JSON.parse(fs.readFileSync(path, 'utf8'));
} catch (e) {
  console.error('Failed to read sessions file:', e);
  process.exit(1);
}
const MAX_TOKENS = 20000; // keep under ~8k tokens
function tokens(text){ return Math.ceil((text||'').length/4); }
let total=0;
for (let i=data.length-1;i>=0;i--){
  total+=tokens(data[i].content);
  if(total>MAX_TOKENS){
    data=data.slice(i+1);
    break;
  }
}
fs.writeFileSync(path, JSON.stringify(data,null,2));
console.log('Pruned sessions to',data.length,'turns, total tokens approx',total);
