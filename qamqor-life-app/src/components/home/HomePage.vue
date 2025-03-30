<template>
  <div class="flex">
    <Navbar />

    <div class="w-full">
      <div class="flex justify-center">
        <div class="ps-4 relative w-[95%]">
          <span class="absolute ps-4 left-3 top-1/2 -translate-y-1/2">
            <v-icon name="io-search" class="text-[#6388A8]" />
          </span>
          <input
            type="text"
            placeholder="поиск"
            class="w-full h-[55px] ps-8 bg-white border-x-[3px] border-b-[3px] rounded-b-[25px] outline-none text-[#6388A8] shadow-sm"
            style="box-shadow: 0 4px 10px #BA6F2E;"
            />
        </div>
      </div>

      <div class="pt-12 h-[550px]">
        <div class="flex justify-center items-center gap-10">
          <div class="h-full rounded-[25px]">
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

      <div class="pl-8 pr-8 space-y-8 pb-8"> 
        <div 
          v-for="(department, index) in departments" 
          :key="index"
          class="bg-white rounded-[25px] flex items-start justify-start text-[#00655A] cursor-pointer shadow-3xl"
          style="box-shadow: 0 4px 10px #E1B89A"
          @click="goToDepartment(department)"
        >
          <div class="p-5 flex flex-col items-start">
            <span class="text-2xl">{{ department.station_name }}</span>  
            <span class="text-sm">{{ department.geolocation.city }}</span>
          </div>
        </div>
      </div>
      
    </div>
  </div>
</template>

<script>
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { ref, onMounted } from "vue";
import { IoSearch } from "oh-vue-icons/icons";
import { useRouter } from "vue-router";

import Calendar from "./Calendar.vue";
import Navbar from "../menu/Navbar.vue";
import StatisticFrame from "./StatisticFrame.vue";
import { useDepartmentStore } from '../../stores/department'


addIcons(IoSearch);

export default {
  name: "HomePage2",
  components: {
    "v-icon": OhVueIcon,
    Calendar,
    StatisticFrame,
    Navbar,
  },
  props: {
    departmentId: {
      type: String,
      required: true,
    },
  },
  setup() {
    const date = ref(new Date());
    const timeAccuracy = ref(3);
    const router = useRouter();
    
    const departments = ref(null);

    function goToStatistics() {
      router.push({
        path: '/statistics',
        query: {
          date: date.value.toISOString(),
        },
      });
    }

    function goToDepartment(department) {
      router.push({
        path: `/department/${department.id}`,
      });
    }

    const getAllDepartments = async () => {
        try {
            const departmentStore = useDepartmentStore();
            const departments_result = await departmentStore.allDepartments();
            departments.value = departments_result;
        } catch (err) {
            console.error("Ошибка при получении продуктов:", err);
            this.error = "Не удалось загрузить продукты";
        }
    };

    onMounted(() => {
      getAllDepartments()
    });
    
    return {
      date,
      timeAccuracy,
      goToStatistics,
      departments,
      goToDepartment
    };
  },
};
</script>