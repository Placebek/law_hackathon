<template>
  <div class="w-[300px]">
    <div class="bg-[#6388A8] h-full text-white p-8">
      <div class="text-[30px] mb-16">Qamqor Life</div>
      
      <div class="flex flex-col gap-6">
        <div class="">
          <button
            @click="openModal"
            class="bg-white text-[#6388A8] cursor-pointer px-4 py-3 rounded-[25px] transition-all duration-200 ease-in-out"
          >
            Добавить нового рабочего
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
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import Add from '../add/Add.vue';

const router = useRouter();

const menuItems = [
  { name: 'home', label: 'Home', path: '/home' },
  { name: 'statistic', label: 'Statistic' },
  { name: 'about', label: 'About' },
  { name: 'settings', label: 'Settings' },
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

const formData = ref({
  name: '',
  position: '',
});


function submitForm() {
  console.log('Данные формы:', formData.value);
  closeModal();
}

</script>
