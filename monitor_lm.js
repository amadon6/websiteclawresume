const { execSync } = require('child_process');
const fs=require('fs');
const sessionsPath='sessions.json';
// Check GPU free memory
let gpu;
try{gpu=JSON.parse(execSync('nvidia-smi --query-gpu=memory.free,memory.total -f -').toString());}
catch(e){console.error('GPU query failed',e);process.exit(1);} // expect array of lines
const [freeStr,totalStr]=gpu.trim().split('\n');
const freeMB=parseInt(freeStr.split(':')[1].trim());
const totalMB=parseInt(totalStr.split(':')[1].trim());
// Estimate session token usage
let data;try{data=JSON.parse(fs.readFileSync(sessionsPath, 'utf8'))}catch(e){console.error('read err',e);process.exit(1);} 
function tokens(t){return Math.ceil((t||'').length/4);} let totalTokens=0;for(const turn of data){totalTokens+=tokens(turn.content);} 
// Log
const log=`GPU ${freeMB}MB free / ${totalMB}MB total | Session turns: ${data.length} | ~${totalTokens} tokens`;
fs.appendFileSync('/tmp/lm_monitor.log',log+'\n');
// Alert if close to limits (e.g., >90% VRAM or >25k tokens)
if(freeMB<4000 || totalTokens>25000){
  console.warn('⚠️ LM likely near limits – consider pruning or reverting model');
}
