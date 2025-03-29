<template>
  <div class="bg-custom-gradient h-full flex justify-start">
    <Navbar />
    <div class="w-full h-full pt-8 pl-8 pr-8">
      <div class="w-full bg-white rounded-t-[25px] p-8 text-black ">
        <div 
          @click="goBack"
          class="text-[#6388A8] text-[18px] pl-5 cursor-pointer flex items-center gap-2 hover:underline"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a.75.75 0 01-.53-.22l-7.5-7.5a.75.75 0 010-1.06l7.5-7.5a.75.75 0 111.06 1.06L3.31 9.25H17a.75.75 0 010 1.5H3.31l7.22 7.22a.75.75 0 01-.53 1.28z" clip-rule="evenodd" />
          </svg>
          Назад
        </div>

        <div class="p-5 flex flex-col items-start space-y-2">
          <span class="text-3xl">Октябрьский отдел полиции УП г. Караганды</span>
          <span class="text-sm">Архитектурная улица, 1 Майкудук м-н, Алихана Бокейхана район, Караганда, Караганда городская администрация, 100001</span>
        </div>
        
        <div>
          <div class="mt-8 text-black">
            <div class="rounded-[25px] flex items-start justify-start p-6 shadow-lg gap-4" style="box-shadow: 0 4px 10px #6388A8">
              <div class="w-[200px] flex-shrink-0">
                <img src="https://photogov-com.akamaized.net/examples/original/US.webp" class="w-[200px] h-64 rounded-[25px] object-cover" />
              </div>
              <div class="p-5 flex flex-col items-start space-y-2">
                <span class="text-2xl">Анатолий Сергей Петрович</span>
                <span class="text-sm">Старший полковник</span>
                <div class="pt-5">
                  <p class="text-[15px]">
                    Процедурная анимация – это метод, при котором движение объектов и персонажей создается автоматически с помощью алгоритмов. В отличие от покадровой или скелетной анимации, процедурная анимация не требует ручного создания каждого кадра.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div class="mt-8 text-black">
            <div class="rounded-[25px] flex items-start justify-start p-6 shadow-lg gap-4" style="box-shadow: 0 4px 10px #6388A8">
              <div class="w-[200px] flex-shrink-0">
                <img src="https://photogov-com.akamaized.net/examples/original/US.webp" class="w-[200px] h-64 rounded-[25px] object-cover" />
              </div>
              <div class="p-5 flex flex-col items-start space-y-2">
                <span class="text-2xl">Анатолий Сергей Петрович</span>
                <span class="text-sm">Старший полковник</span>
                <div class="pt-5">
                  <p class="text-[15px]">
                    Процедурная анимация – это метод, при котором движение объектов и персонажей создается автоматически с помощью алгоритмов. В отличие от покадровой или скелетной анимации, процедурная анимация не требует ручного создания каждого кадра.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div class="mt-8 text-black">
            <div class="rounded-[25px] flex items-start justify-start p-6 shadow-lg gap-4" style="box-shadow: 0 4px 10px #6388A8">
              <div class="w-[200px] flex-shrink-0">
                <img src="https://photogov-com.akamaized.net/examples/original/US.webp" class="w-[200px] h-64 rounded-[25px] object-cover" />
              </div>
              <div class="p-5 flex flex-col items-start space-y-2">
                <span class="text-2xl">Анатолий Сергей Петрович</span>
                <span class="text-sm">Старший полковник</span>
                <div class="pt-5">
                  <p class="text-[15px]">
                    Процедурная анимация – это метод, при котором движение объектов и персонажей создается автоматически с помощью алгоритмов. В отличие от покадровой или скелетной анимации, процедурная анимация не требует ручного создания каждого кадра.
                  </p>
                </div>
              </div>
            </div>
          </div>

        </div>
        
      </div>
    </div>
  </div>
</template>

<script>
import { useRouter } from 'vue-router';
import Navbar from "../menu/Navbar.vue";

export default {
  name: "Department",
  components: {
    Navbar,
  },
  setup() {
    const router = useRouter();

    const goBack = () => {
      router.back();
    };

    return {
      goBack,
    };
  },
};
</script>
