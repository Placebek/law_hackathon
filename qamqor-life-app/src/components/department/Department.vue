<template>
  <div class="flex min-h-screen">
    <Navbar />
    <div class="w-full pt-8 pl-8 pr-8">
      <div class="bg-white h-full rounded-t-[25px] p-8 text-[#004D45]">
        <div 
          @click="goBack"
          class="text-[#377973] text-[18px] pl-5 cursor-pointer flex items-center gap-2 hover:underline"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a.75.75 0 01-.53-.22l-7.5-7.5a.75.75 0 010-1.06l7.5-7.5a.75.75 0 111.06 1.06L3.31 9.25H17a.75.75 0 010 1.5H3.31l7.22 7.22a.75.75 0 01-.53 1.28z" clip-rule="evenodd" />
          </svg>
          Назад
        </div>

        <div v-if="department" class="p-5 flex flex-col items-start space-y-2">
          <span class="text-3xl">{{ department.station_name }}</span>
          <span class="text-sm">{{ department.geolocation.city }} / {{ department.geolocation.street }}</span>
        </div>

        <div 
          v-if="department" 
          v-for="(policeman, index) in department.policemans" 
          :key="index"
          @click="goToPolicemanProfile(policeman)"
        > 
          <div class="mt-8 text-[#004D45]">
            <div class="rounded-[25px] flex items-start justify-start p-6 shadow-lg gap-4" style="box-shadow: 0 4px 10px #A14200">
              <div class="w-[200px] flex-shrink-0">
                <img src="https://photogov-com.akamaized.net/examples/original/US.webp" class="w-[200px] h-64 rounded-[25px] object-cover" />
              </div>
              <div class="p-5 flex flex-col items-start space-y-2">
                <span class="text-2xl">{{ policeman.first_name }} {{ policeman.last_name }}</span>
                <span class="text-sm">{{ policeman.rank.name }}</span>
                <div class="pt-5">
                  <p class="text-[15px]">
                    {{ truncate(policeman.resume) }}
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
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from 'vue-router';
import Navbar from "../menu/Navbar.vue";
import { useDepartmentStore } from '../../stores/department';

export default {
  name: "Department",
  components: {
    Navbar,
  },
  props: {
    departmentId: {
      type: String,
      required: true,
    },
  },
  setup() {
    const route = useRoute();
    const router = useRouter();
    const departmentId = route.params.id;
    const department = ref(null);

    const goBack = () => {
      router.back();
    };

    const getDepartment = async () => {
      try {
        const departmentStore = useDepartmentStore();
        const department_result = await departmentStore.getDepartmentByID(departmentId);
        department.value = department_result;
      } catch (err) {
        console.error("Ошибка при получении данных:", err);
      }
    };

    const truncate = (text, length = 600) => {
      if (!text) return "";
      return text.length > length ? text.slice(0, length) + "..." : text;
    };

    function goToPolicemanProfile(policeman) {
      router.push({
        path: `/profile/${policeman.id}`,
      });
    }

    onMounted(() => {
      getDepartment();
    });

    return {
      goBack,
      department,
      goToPolicemanProfile,
      truncate,
    };
  },
};
</script>
