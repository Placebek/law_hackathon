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


        <div class="mt-8 bg-white p-8 rounded-lg shadow-xl w-[98%] mx-auto h-full" style="box-shadow: 0 4px 10px #6388A8">
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h2 class="text-2xl font-bold text-gray-800">Анатолий Сергей Петрович</h2>
              <p class="text-lg text-gray-600">Старший полковник</p>
              <p class="text-base text-gray-700 mt-4">
                <span class="font-semibold">Отдел полиции:</span> Октябрьский отдел полиции УП г. Караганды<br>
                <span class="font-semibold">Стаж:</span> 20 лет<br>
                <span class="font-semibold">Область ответственности:</span> обеспечение общественной безопасности, расследование преступлений, контроль оперативных мероприятий<br>
                <span class="font-semibold">Дополнительно:</span> Высокий уровень профессионализма, лидерские качества, награжден многочисленными наградами.
              </p>
            </div>
            <div class="flex-shrink-0 w-[200px] ml-8">
              <img src="https://photogov-com.akamaized.net/examples/original/US.webp" alt="Фото полковника" class="w-full h-64 rounded-lg object-cover" />
            </div>
            <div>
            </div>
          </div>
          <div class="mt-6">
            Ниже приведён пример кода карточки резюме для полицейского, где информация располагается слева, а фотография – справа. Я добавил вымышленные данные, такие как имя, звание, отдел, стаж, область ответственности и дополнительные сведения. Вы можете подстроить данные и стили под свои нужды.
            Ниже приведён пример кода карточки резюме для полицейского, где информация располагается слева, а фотография – справа. Я добавил вымышленные данные, такие как имя, звание, отдел, стаж, область ответственности и дополнительные сведения. Вы можете подстроить данные и стили под свои нужды.
            Ниже приведён пример кода карточки резюме для полицейского, где информация располагается слева, а фотография – справа. Я добавил вымышленные данные, такие как имя, звание, отдел, стаж, область ответственности и дополнительные сведения. Вы можете подстроить данные и стили под свои нужды.
            Ниже приведён пример кода карточки резюме для полицейского, где информация располагается слева, а фотография – справа. Я добавил вымышленные данные, такие как имя, звание, отдел, стаж, область ответственности и дополнительные сведения. Вы можете подстроить данные и стили под свои нужды.
          </div>
        </div>


      </div>
    </div>
  </div>
</template>


<script setup>
import { ref, computed } from 'vue'
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { IoSearch } from "oh-vue-icons/icons";
import Navbar from "../menu/Navbar.vue";

import { useRouter } from 'vue-router';

const router = useRouter();

function goBack() {
  router.back();
}

addIcons(IoSearch);

</script>