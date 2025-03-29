<template>
  <div class="bg-custom-gradient h-full flex justify-start">
    <Navbar />

    <div class="w-full text-white">
      <div class="flex justify-center items-start">
        <div class="ml-4 relative w-[95%]">
          <span class="absolute pl-3 left-3 top-1/2 -translate-y-1/2">
            <v-icon name="io-search" class="text-[#6388A8]" />
          </span>
          <input
            type="text"
            placeholder="search"
            class="w-full h-[55px] p-3 pl-[5%] bg-white border-x-[3px] border-b-[4px] border-[#BA6F2E] rounded-b-[25px] outline-none text-[#6388A8]"
          />
        </div>
      </div>

      <div class="p-8 pt-12 h-[550px]">
        <div class="flex justify-center items-center gap-4">
          <div class="w-2/3 h-full rounded-[25px]">
            <StatisticFrame
              :selected-date="date"
              class="cursor-pointer"
              @click="goToStatistics"
            />
          </div>
          <div class="w-1/3">
            <Calendar v-model="date" />
          </div>
        </div>
      </div>

      <div class="pl-8 pr-8">
        <div class="bg-white rounded-[25px] flex items-start justify-start p-4 text-[#6388A8]">
          <div class="p-5 flex flex-col items-start space-y-2">
            <span class="text-2xl">Октябрьский отдел полиции УП г. Караганды </span>  
            <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
          </div>
        </div>
        <div class="bg-white mt-8 rounded-[25px] flex items-start justify-start p-4 text-[#6388A8]">
          <div class="p-5 flex flex-col items-start space-y-2">
            <span class="text-2xl">Октябрьский отдел полиции УП г. Караганды </span>  
            <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
          </div>
        </div>
        <div class="bg-white mt-8 rounded-[25px] flex items-start justify-start p-4 text-[#6388A8]">
          <div class="p-5 flex flex-col items-start space-y-2">
            <span class="text-2xl">Октябрьский отдел полиции УП г. Караганды </span>  
            <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
          </div>
        </div>
        <div class="bg-white mt-8 rounded-[25px] flex items-start justify-start p-4 text-[#6388A8]">
          <div class="p-5 flex flex-col items-start space-y-2">
            <span class="text-2xl">Октябрьский отдел полиции УП г. Караганды </span>  
            <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
          </div>
        </div>
        <div class="bg-white mt-8 rounded-[25px] flex items-start justify-start p-4 text-[#6388A8]">
          <div class="p-5 flex flex-col items-start space-y-2">
            <span class="text-2xl">Октябрьский отдел полиции УП г. Караганды </span>  
            <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
          </div>
        </div>
      </div>
      
      </div>
  </div>
</template>

<script>
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { IoSearch } from "oh-vue-icons/icons";
import { ref } from "vue";
import { useRouter } from "vue-router";

import Calendar from "./Calendar.vue";
import Navbar from "../menu/Navbar.vue";
import StatisticFrame from "./StatisticFrame.vue";

addIcons(IoSearch);

export default {
  name: "HomePage",
  components: {
    "v-icon": OhVueIcon,
    Calendar,
    StatisticFrame,
    Navbar,
  },
  setup() {
    const date = ref(new Date());
    const timeAccuracy = ref(3);
    const router = useRouter();
    
    function goToStatistics() {
      router.push({
        path: '/statistics',
        query: {
          date: date.value.toISOString(),
        },
      });
    }
    
    return {
      date,
      timeAccuracy,
      goToStatistics,
    };
  },
};
</script>