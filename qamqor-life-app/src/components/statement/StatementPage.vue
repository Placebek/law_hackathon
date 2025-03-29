<template>
  <div class="bg-custom-gradient h-full flex justify-start">
    <Navbar />

    <div class="w-full h-full pt-8 pl-8 pr-8">
      <div class="w-full bg-white rounded-t-[25px] p-8 text-black ">
        <div 
          @click="goBack"
          class="text-[#377973] text-[18px] pl-5 cursor-pointer flex items-center gap-2 hover:underline"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a.75.75 0 01-.53-.22l-7.5-7.5a.75.75 0 010-1.06l7.5-7.5a.75.75 0 111.06 1.06L3.31 9.25H17a.75.75 0 010 1.5H3.31l7.22 7.22a.75.75 0 01-.53 1.28z" clip-rule="evenodd" />
          </svg>
          Назад
        </div>


        <div v-if="statement" class="mt-8 bg-white text-[#005047] p-8 rounded-2xl shadow-sm w-[98%] mx-auto h-full" style="box-shadow: 0 4px 10px #A14200">
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h2 class="text-2xl font-bold ">{{ statement.recipient }} {{ statement.recipient }}</h2>
              <p class="text-lg">{{ statement.policeman.first_name }}</p>
              <p class="text-base mt-4">
                <span class="font-semibold">Отдел полиции:</span> Октябрьский отдел полиции УП г. Караганды<br>
                <span class="font-semibold">Стаж:</span> 20 лет<br>
                <span class="font-semibold">Год рождения: </span>{{ statement.birth_day }}<br>
                <span class="font-semibold">Область ответственности:</span> обеспечение общественной безопасности, расследование преступлений, контроль оперативных мероприятий<br>
                <span class="font-semibold">Дополнительно:</span> Высокий уровень профессионализма, лидерские качества, награжден многочисленными наградами.
              </p>
            </div>
            <div class="flex-shrink-0 w-[200px] ml-8">
              <div></div>
            </div>
            <div>
            </div>
          </div>
          <div class="mt-6">
            {{ statement.resume }}  
          </div>
        </div>


      </div>
    </div>
  </div>
</template>


<script>
import { ref, onMounted} from "vue";
import { useRoute, useRouter } from 'vue-router';
import Navbar from "../menu/Navbar.vue";

import { useStatementStore } from "../../stores/statement"


export default {
  name: "StatementPage",
  components: {
    Navbar,
  },
  props: {
    statementId: {
      type: String,
      required: true,
    },
  },
  setup() {
    const statement = ref(null);
    const route = useRoute();
    const router = useRouter();

    function goBack() {
      router.back();
    }

    const statementId = route.params.id;

    const getStatementDate = async () => {
        try {
            const statementStore = useStatementStore();
            const statement_result = await statementStore.getStatementByID(statementId);

            // const dateStr = policeman_result.birth_day;
            // const dateObj = new Date(dateStr);

            // const day = ("0" + dateObj.getDate()).slice(-2); // "28"
            // const month = ("0" + (dateObj.getMonth() + 1)).slice(-2); // "03" (месяцы с 0, поэтому +1)
            // const year = dateObj.getFullYear(); // 2025

            // statement_result.birth_day = `${day}.${month}.${year}`;

            statement.value = statement_result;
            debugger
        } catch (err) {
            console.error("Ошибка при получении продуктов:", err);
            this.error = "Не удалось загрузить продукты";
        }
    };

    onMounted(() => {
      debugger
      getStatementDate()
    });

    return {
      goBack,
      statement
    };
  },
};
</script>
