<template>
  <div class="bg-custom-gradient h-full flex justify-start">
    <Navbar />

    <div class="w-full h-full pt-8 pl-8 pr-8">
      <div class="w-full bg-white rounded-t-[25px] p-8 text-black ">
        <div class="flex items-center justify-between w-full">
          <div 
            @click="goBack"
            class="text-[#377973] text-[18px] pl-5 cursor-pointer flex items-center gap-2 hover:underline"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a.75.75 0 01-.53-.22l-7.5-7.5a.75.75 0 010-1.06l7.5-7.5a.75.75 0 111.06 1.06L3.31 9.25H17a.75.75 0 010 1.5H3.31l7.22 7.22a.75.75 0 01-.53 1.28z" clip-rule="evenodd" />
            </svg>
            Назад
          </div>
          <div>
            <button 
              @click="openModal" 
              class="bg-[#C46412] text-white px-4 py-2 rounded-[25px] shadow-md hover:bg-[#a3530f] transition mr-2"
            >
              Удалить
            </button>
          </div>
        </div>

        <div v-if="isModalOpen">
          <AreYouSure @close="closeModal" />
        </div>

        <div v-if="policeman" class="mt-8 bg-white text-[#005047] p-8 rounded-2xl shadow-sm w-[98%] mx-auto h-full" style="box-shadow: 0 4px 10px #A14200">
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h2 class="text-2xl font-bold ">{{ policeman.first_name }} {{ policeman.last_name }}</h2>
              <div v-if="policeman.rank.name">
                <p class="text-lg">{{ policeman.rank.name }}</p>
              </div>
              <p class="text-base mt-4">
                <span class="font-semibold">Отдел полиции:</span> {{ policeman.station.station_name }}<br>
                <span class="font-semibold">Стаж:</span> 20 лет<br>
                <span class="font-semibold">Год рождения: </span>{{ policeman.birth_day }}<br>
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
            {{ policeman.resume }}  
          </div>
        </div>


      </div>
    </div>
  </div>
</template>






<script>
import { ref, onMounted, computed} from "vue";
import { useRoute, useRouter } from 'vue-router';
import Navbar from "../menu/Navbar.vue";

import AreYouSure from '../add/AreYouSure.vue'

import { usePolicemanStore } from "../../stores/policeman";


export default {
  name: "ProfilePage",
  components: {
    Navbar,
    AreYouSure,
  },
  props: {
    policemanId: {
      type: String,
      required: true,
    },
  },
  setup() {
    const policeman = ref(null);
    const route = useRoute();
    const router = useRouter();

    function goBack() {
      router.back();
    }

    const isModalOpen = ref(false);

    const openModal = () => {
      isModalOpen.value = true;
    };

    const closeModal = () => {
      isModalOpen.value = false;
    };

    const policemanId = route.params.id;

    const getPolicemanDate = async () => {
        try {
            const policemanStore = usePolicemanStore();
            const policeman_result = await policemanStore.getPolicemanByID(policemanId);

            const dateStr = policeman_result.birth_day;
            const dateObj = new Date(dateStr);

            const day = ("0" + dateObj.getDate()).slice(-2);
            const month = ("0" + (dateObj.getMonth() + 1)).slice(-2);
            const year = dateObj.getFullYear();

            policeman_result.birth_day = `${day}.${month}.${year}`;

            policeman.value = policeman_result;
            debugger
        } catch (err) {
            console.error("Ошибка при получении продуктов:", err);
            this.error = "Не удалось загрузить продукты";
        }
    };

    onMounted(() => {
      getPolicemanDate()
    });

    return {
      goBack,
      policeman,
      openModal,
      closeModal,
      isModalOpen,
    };
  },
};
</script>
