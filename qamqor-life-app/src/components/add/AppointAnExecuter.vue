<template>
  <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 w-full">
    <div class="bg-white flex flex-col justify-center p-6 rounded-[25px] shadow-lg w-[30%] h-[50%] relative text-center">
      <h2 class="text-xl font-semibold mb-4">Назначение исполнителя</h2>

      <div ref="departmentWrapper" class="relative w-full mb-6">
        <button 
          @click="toggleDepartmentDropdown" 
          class="bg-[#C46412] text-white px-4 py-2 rounded-[25px] shadow-md hover:bg-[#a3530f] transition flex items-center justify-between w-full"
        >
          <span>{{ selectedDepartment.station_name || "Выберите департамент" }}</span>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 ml-2" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M5.23 7.23a.75.75 0 011.06 0L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.23 8.29a.75.75 0 010-1.06z" clip-rule="evenodd" />
          </svg>
        </button>

        <transition name="fade">
          <div 
            v-if="isDepartmentOpen" 
            ref="departmentDropdown"
            class="absolute left-0 mt-2 w-full bg-white border border-gray-200 rounded-[25px] shadow-lg z-10 max-h-60 overflow-auto"
          >
            <ul>
              <li 
                v-for="dept in departments" 
                :key="dept.id" 
                @click="selectDepartment(dept)"
                class="px-4 py-2 cursor-pointer hover:bg-gray-100 transition"
              >
                {{ dept.station_name }}
              </li>
            </ul>
          </div>
        </transition>
      </div>

      <div v-if="selectedDepartment.id" ref="executersWrapper" class="relative w-full mb-6">
        <button 
          @click="toggleExecutersDropdown" 
          class="bg-[#C46412] text-white px-4 py-2 rounded-[25px] shadow-md hover:bg-[#a3530f] transition flex items-center justify-between w-full"
        >
          <span>{{ selectedExecuter ? selectedExecuter.first_name : "Выберите исполнителя" }}</span>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 ml-2" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M5.23 7.23a.75.75 0 011.06 0L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.23 8.29a.75.75 0 010-1.06z" clip-rule="evenodd" />
          </svg>
        </button>

        <transition name="fade">
          <div 
            v-if="isExecutersOpen" 
            ref="executersDropdown"
            class="absolute mt-2 w-full bg-white border border-gray-200 rounded-[25px] shadow-lg z-10 max-h-60 overflow-auto"
          >
            <ul>
              <li 
                v-for="policeman in filteredExecuters" 
                :key="policeman.id"
                @click="selectExecuter(policeman)" 
                class="px-4 py-2 cursor-pointer hover:bg-gray-100 transition"
              >
                {{ policeman.first_name }} {{ policeman.last_name }}
              </li>
            </ul>
          </div>
        </transition>
      </div>
      
      <div class="flex justify-end mt-4">
        <button 
          @click="closeModal" 
          class="bg-gray-300 text-gray-700 px-4 py-2 rounded-[25px] mr-2 hover:bg-gray-400 transition"
        >
          Отмена
        </button>
        <button 
          @click="appointExecuter"
          class="bg-[#C46412] text-white px-4 py-2 rounded-[25px] hover:bg-[#a3530f] transition"
        >
          Назначить
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useDepartmentStore } from '../../stores/department';

const props = defineProps({
  statementId: {
    type: Number,
    required: true,
  }
});

const emit = defineEmits(['close', 'appoint']);

const isDepartmentOpen = ref(false);
const isExecutersOpen = ref(false);
const selectedDepartment = ref({});
const selectedExecuter = ref(null);
const departmentData = ref({});

const departments = ref([]);

const getDepartment = async () => {
  try {
    const departmentStore = useDepartmentStore();
    const departments_result = await departmentStore.allDepartments();
    departments.value = departments_result;
  } catch (err) {
    console.error("Ошибка при получении департаментов:", err);
  }
};

const getDepartmentByID = async (departmentId) => {
  try {
    const departmentStore = useDepartmentStore();
    const dept = await departmentStore.getDepartmentByID(departmentId);
    departmentData.value = dept;
  } catch (err) {
    console.error("Ошибка при получении департамента:", err);
  }
};

const updateStatementByID = async (statementId, policemanId) => {
  try {
    const departmentStore = useDepartmentStore();
    await departmentStore.updateStatement(statementId, policemanId);
  } catch (err) {
    console.error("Ошибка при обновлении заявления:", err);
  }
};

const filteredExecuters = computed(() => {
  return departmentData.value?.policemans || [];
});

const departmentWrapper = ref(null);
const executersWrapper = ref(null);

const toggleDepartmentDropdown = () => {
  isDepartmentOpen.value = !isDepartmentOpen.value;
};

const toggleExecutersDropdown = () => {
  isExecutersOpen.value = !isExecutersOpen.value;
};

const selectDepartment = (dept) => {
  selectedDepartment.value = dept;
  selectedExecuter.value = null;
  isDepartmentOpen.value = false;
  getDepartmentByID(dept.id);
};

const selectExecuter = (policeman) => {
  selectedExecuter.value = policeman;
  isExecutersOpen.value = false;
};

const handleClickOutside = (event) => {
  if (departmentWrapper.value && !departmentWrapper.value.contains(event.target)) {
    isDepartmentOpen.value = false;
  }
  if (executersWrapper.value && !executersWrapper.value.contains(event.target)) {
    isExecutersOpen.value = false;
  }
};

const closeModal = () => {
  emit('close');
};

const appointExecuter = async () => {
  if (!selectedDepartment.value.id || !selectedExecuter.value?.id) {
    console.error("Не выбран департамент или сотрудник");
    return;
  }
  await updateStatementByID(props.statementId, selectedExecuter.value.id);
  emit('appoint', { department: selectedDepartment.value, executer: selectedExecuter.value });
  closeModal();
};

onMounted(() => {
  document.addEventListener("click", handleClickOutside);
  getDepartment();
});

onUnmounted(() => {
  document.removeEventListener("click", handleClickOutside);
});
</script>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s ease-in-out;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
