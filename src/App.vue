<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import db from './db.json'; // 引入我們的 JSON 資料庫

// 狀態管理
const currentEventIndex = ref(0);
const now = ref(new Date());
const timer = ref(null);

// 切換事件
const currentEvent = computed(() => db.events[currentEventIndex.value]);

// 倒數計時核心邏輯
const timeLeft = computed(() => {
  const target = new Date(currentEvent.value.date).getTime();
  const current = now.value.getTime();
  const diff = target - current;

  if (diff <= 0) return { finished: true };

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  return { finished: false, days, hours, minutes, seconds };
});

// 啟動與銷毀 Timer
onMounted(() => {
  timer.value = setInterval(() => {
    now.value = new Date();
  }, 1000);
});

onUnmounted(() => {
  clearInterval(timer.value);
});

// 格式化日期顯示
const formatDate = (dateStr) => {
  const d = new Date(dateStr);
  return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, '0')}.${String(d.getDate()).padStart(2, '0')}`;
};
</script>

<template>
  <div class="min-h-screen flex flex-col items-center justify-between p-6 relative overflow-hidden font-mono">
    
    <div class="absolute top-0 w-full bg-slate-800 text-xs py-1 px-4 text-center text-slate-400">
      待辦提醒：{{ db.reminders.join(' | ') }}
    </div>

    <header class="mt-8 text-center z-10">
      <h1 class="text-3xl md:text-5xl font-bold tracking-wider text-green-400 drop-shadow-lg">
        {{ currentEvent.title }}
      </h1>
      <p class="text-xl text-slate-400 mt-4 tracking-widest">
        {{ formatDate(currentEvent.date) }}
      </p>
    </header>

    <main class="flex-grow flex flex-col justify-center items-center z-10 w-full relative">
      
      <div v-if="!timeLeft.finished" class="grid grid-cols-2 md:grid-cols-4 gap-4 text-center w-full max-w-4xl">
        <div class="p-4 bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
          <span class="block text-6xl md:text-8xl font-bold text-white">{{ timeLeft.days }}</span>
          <span class="text-sm text-slate-400 uppercase">Days</span>
        </div>
        <div class="p-4 bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
          <span class="block text-6xl md:text-8xl font-bold text-white">{{ String(timeLeft.hours).padStart(2, '0') }}</span>
          <span class="text-sm text-slate-400 uppercase">Hours</span>
        </div>
        <div class="p-4 bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
          <span class="block text-6xl md:text-8xl font-bold text-white">{{ String(timeLeft.minutes).padStart(2, '0') }}</span>
          <span class="text-sm text-slate-400 uppercase">Minutes</span>
        </div>
        <div class="p-4 bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
          <span class="block text-6xl md:text-8xl font-bold text-green-400">{{ String(timeLeft.seconds).padStart(2, '0') }}</span>
          <span class="text-sm text-slate-400 uppercase">Seconds</span>
        </div>
      </div>

      <div v-else class="absolute inset-0 flex items-center justify-center bg-yellow-500/30 backdrop-blur-md rounded-3xl border border-yellow-400/50 shadow-[0_0_50px_rgba(234,179,8,0.5)] z-50">
        <h2 class="text-6xl font-black text-yellow-100 drop-shadow-md">成功 😉!</h2>
      </div>

    </main>

    <footer class="w-full max-w-5xl z-10 mb-8">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <button 
          v-for="(event, index) in db.events" 
          :key="event.id"
          @click="currentEventIndex = index"
          class="p-4 rounded-lg transition-all duration-300 border text-left hover:scale-105 active:scale-95"
          :class="currentEventIndex === index 
            ? 'bg-green-600 border-green-400 text-white shadow-[0_0_15px_rgba(34,197,94,0.6)]' 
            : 'bg-slate-800 border-slate-700 text-slate-400 hover:bg-slate-700'"
        >
          <div class="font-bold truncate text-sm md:text-base">{{ event.title }}</div>
          <div class="text-xs opacity-70 mt-1">{{ formatDate(event.date) }}</div>
        </button>
      </div>
    </footer>

  </div>
</template>