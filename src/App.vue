<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue';
import { CountUp } from 'countup.js'; // 引入動畫庫
import db from './db.json';

const currentEventIndex = ref(0);
const now = ref(new Date());
const timer = ref(null);

// DOM 元素的參考 (讓 CountUp 抓得到)
const daysRef = ref(null);
const hoursRef = ref(null);
const minutesRef = ref(null);
const secondsRef = ref(null);

// 動畫狀態旗標
const isAnimating = ref(true);

const currentEvent = computed(() => db.events[currentEventIndex.value]);

// 核心倒數邏輯
const timeLeft = computed(() => {
  const target = new Date(currentEvent.value.date).getTime();
  const current = now.value.getTime();
  const diff = target - current;

  if (diff <= 0) return { finished: true, days: 0, hours: 0, minutes: 0, seconds: 0 };

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  return { finished: false, days, hours, minutes, seconds };
});

// 格式化日期
const formatDate = (dateStr) => {
  const d = new Date(dateStr);
  return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, '0')}.${String(d.getDate()).padStart(2, '0')}`;
};

// 啟動 CountUp 動畫
const startAnimation = () => {
  isAnimating.value = true;
  
  // CountUp 通用設定
  const options = {
    duration: 2.5, // 動畫時間 2.5 秒
    useEasing: true, 
    useGrouping: false, // 不要千分位逗號
    // 關鍵：讓動畫過程也保持 "05" 這種兩位數格式
    formattingFn: (n) => String(n).padStart(2, '0') 
  };
  
  // Days 特別設定 (天數不用補零，且可能很大)
  const daysOptions = { ...options, formattingFn: undefined };

  // 建立動畫實例
  const animDays = new CountUp(daysRef.value, timeLeft.value.days, daysOptions);
  const animHours = new CountUp(hoursRef.value, timeLeft.value.hours, options);
  const animMinutes = new CountUp(minutesRef.value, timeLeft.value.minutes, options);
  const animSeconds = new CountUp(secondsRef.value, timeLeft.value.seconds, options);

  // 開始動畫
  animDays.start();
  animHours.start();
  animMinutes.start();
  
  // 以「秒」的動畫結束為基準，交接給 Vue
  animSeconds.start(() => {
    // 動畫結束 callback
    isAnimating.value = false; 
  });
};

onMounted(() => {
  // 1. 啟動計時器
  timer.value = setInterval(() => { now.value = new Date(); }, 1000);
  
  // 2. 啟動進場動畫
  startAnimation();
});

onUnmounted(() => {
  clearInterval(timer.value);
});

// 當使用者切換事件時，也可以重播動畫 (選用功能)
const switchEvent = (index) => {
  currentEventIndex.value = index;
  // 重置 DOM 並重新觸發動畫
  isAnimating.value = true; 
  // 等待 Vue DOM 更新後再跑動畫
  nextTick(() => {
    startAnimation();
  });
};
</script>

<template>
  <div class="min-h-[100dvh] flex flex-col items-center justify-between p-4 sm:p-8 relative overflow-hidden font-mono bg-slate-900 text-slate-200">
    
    <div class="absolute top-0 w-full bg-slate-800/80 backdrop-blur text-[10px] sm:text-xs py-1 px-4 text-center text-slate-400 border-b border-slate-700/50">
      待辦提醒：{{ db.reminders.join(' | ') }}
    </div>

    <header class="mt-8 sm:mt-12 text-center z-10 w-full max-w-4xl mx-auto px-2">
      <h1 class="text-2xl sm:text-4xl lg:text-5xl font-black tracking-wider text-green-400 drop-shadow-[0_0_15px_rgba(74,222,128,0.5)] break-words">
        {{ currentEvent.title }}
      </h1>
      <p class="text-base sm:text-xl text-slate-400 mt-2 sm:mt-4 tracking-[0.2em] font-light">
        {{ formatDate(currentEvent.date) }}
      </p>
    </header>

    <main class="flex-grow flex flex-col justify-center items-center z-10 w-full relative py-4">
      
      <div v-if="!timeLeft.finished" class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-6 text-center w-full max-w-5xl px-2">
        
        <div class="group p-3 sm:p-6 bg-slate-800/40 rounded-2xl backdrop-blur-md border border-slate-700/50 shadow-lg hover:border-green-500/30 transition-colors">
          <span ref="daysRef" class="block text-4xl sm:text-6xl lg:text-8xl font-bold text-white tabular-nums tracking-tighter group-hover:text-green-300 transition-colors">
            {{ isAnimating ? '' : timeLeft.days }}
          </span>
          <span class="text-[10px] sm:text-sm text-slate-500 uppercase font-semibold tracking-widest mt-1 sm:mt-2 block">Days</span>
        </div>

        <div class="group p-3 sm:p-6 bg-slate-800/40 rounded-2xl backdrop-blur-md border border-slate-700/50 shadow-lg hover:border-green-500/30 transition-colors">
          <span ref="hoursRef" class="block text-4xl sm:text-6xl lg:text-8xl font-bold text-white tabular-nums tracking-tighter group-hover:text-green-300 transition-colors">
            {{ isAnimating ? '' : String(timeLeft.hours).padStart(2, '0') }}
          </span>
          <span class="text-[10px] sm:text-sm text-slate-500 uppercase font-semibold tracking-widest mt-1 sm:mt-2 block">Hours</span>
        </div>

        <div class="group p-3 sm:p-6 bg-slate-800/40 rounded-2xl backdrop-blur-md border border-slate-700/50 shadow-lg hover:border-green-500/30 transition-colors">
          <span ref="minutesRef" class="block text-4xl sm:text-6xl lg:text-8xl font-bold text-white tabular-nums tracking-tighter group-hover:text-green-300 transition-colors">
             {{ isAnimating ? '' : String(timeLeft.minutes).padStart(2, '0') }}
          </span>
          <span class="text-[10px] sm:text-sm text-slate-500 uppercase font-semibold tracking-widest mt-1 sm:mt-2 block">Minutes</span>
        </div>

        <div class="group p-3 sm:p-6 bg-slate-800/40 rounded-2xl backdrop-blur-md border border-slate-700/50 shadow-lg hover:border-green-500/30 transition-colors">
          <span ref="secondsRef" class="block text-4xl sm:text-6xl lg:text-8xl font-bold text-green-400 tabular-nums tracking-tighter shadow-green-400/20 drop-shadow-sm">
             {{ isAnimating ? '' : String(timeLeft.seconds).padStart(2, '0') }}
          </span>
          <span class="text-[10px] sm:text-sm text-slate-500 uppercase font-semibold tracking-widest mt-1 sm:mt-2 block">Seconds</span>
        </div>
      </div>

      <div v-else class="absolute inset-4 sm:inset-10 flex items-center justify-center bg-yellow-500/20 backdrop-blur-lg rounded-3xl border border-yellow-400/30 shadow-[0_0_100px_rgba(234,179,8,0.2)] z-50 animate-pulse">
        <h2 class="text-4xl sm:text-6xl lg:text-8xl font-black text-yellow-100 drop-shadow-lg text-center leading-tight">
          MISSION<br>COMPLETE
        </h2>
      </div>

    </main>

    <footer class="w-full max-w-5xl z-10 mt-4 sm:mb-4">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-2 sm:gap-4">
        <button 
          v-for="(event, index) in db.events" 
          :key="event.id"
          @click="switchEvent(index)" 
          class="p-3 sm:p-4 rounded-xl transition-all duration-300 border text-left hover:scale-[1.02] active:scale-95 flex flex-col justify-center"
          :class="currentEventIndex === index 
            ? 'bg-green-600/90 border-green-400 text-white shadow-[0_0_20px_rgba(34,197,94,0.4)] ring-1 ring-green-400' 
            : 'bg-slate-800/50 border-slate-700 text-slate-400 hover:bg-slate-700 hover:text-slate-200'"
        >
          <div class="font-bold text-xs sm:text-sm lg:text-base truncate w-full">{{ event.title }}</div>
          <div class="text-[10px] sm:text-xs opacity-70 mt-1 font-mono">{{ formatDate(event.date) }}</div>
        </button>
      </div>
    </footer>

  </div>
</template>