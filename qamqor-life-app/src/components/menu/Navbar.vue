<template>
  <div class="bg-[#3B938A] text-white p-8">
      <div class="text-[30px] mb-10 flex justify-center flex-col items-center">
        <div class="">
          <img src="../../assets/img/logo2.png" alt="" class="w-[90px] h-[75px]">
        </div>
        <div class="text-glow">
          Qamqor Life
        </div>
      </div>

      <div class="flex flex-col gap-6">
        <div class="">
          <button
            @click="openModal"
            class="bg-[#F3FFDE] text-[#6388A8] cursor-pointer px-4 py-3 rounded-[25px] transition-all duration-200 ease-in-out"
          >
            Добавить нового исполнителя
          </button>

          <div
            v-if="isModalOpen"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
          > 
            <Add @close="closeModal" />

          </div>
        </div>

        <div
          v-for="item in menuItems"
          :key="item.name"
          @click="navigate(item)"
          :class="[ 
            'cursor-pointer px-4 py-3 rounded-[25px] transition-all duration-200 ease-in-out',
            activeItem === item.name 
              ? 'bg-white text-[#6388A8]' 
              : 'text-white hover:bg-white hover:text-[#6388A8]'
          ]"
        >
          {{ item.label }}
        </div>
      </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import Add from '../add/Add.vue';

const router = useRouter();

const menuItems = [
  { name: 'home', label: 'Главное окно', path: '/home' },
  { name: 'about', label: 'О нас' },
  { name: 'settings', label: 'Настройки' },
];


const activeItem = ref('home');

const navigate = (item) => {
  activeItem.value = item.name;
  router.push(item.path);
};

const isModalOpen = ref(false)

function openModal() {
  isModalOpen.value = true
}
function closeModal() {
  isModalOpen.value = false
}

</script>


<style>
.text-glow {
  font-size: 24px;
  font-weight: bold;
  color: #fff; 
  text-shadow: 0 0 80px #8ee7de, 0 0 50px #8ee7de, 0 0 50px #8ee7de;
}
</style>