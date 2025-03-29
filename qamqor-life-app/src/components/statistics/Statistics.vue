<template>
  <div class="bg-custom-gradient flex">
    <Navbar />
    <div class="w-full px-8 pt-8">
      <div class="w-full bg-white rounded-t-[25px] p-8 text-black ">
        <div class="flex justify-between">
          <div 
            @click="goBack"
            class="text-[#377973] text-[18px] pl-5 cursor-pointer flex items-center gap-2 hover:underline"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a.75.75 0 01-.53-.22l-7.5-7.5a.75.75 0 010-1.06l7.5-7.5a.75.75 0 111.06 1.06L3.31 9.25H17a.75.75 0 010 1.5H3.31l7.22 7.22a.75.75 0 01-.53 1.28z" clip-rule="evenodd" />
            </svg>
            Назад
          </div>
          
          <div class="bg-[#00655A] rounded-2xl text-white p-3 text-[18px]">
            {{ formattedDate }}
          </div>
        </div>
        
        <div class="pt-16 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div></div>
            <div>full name</div>
            <div>Заявленный</div>
            <div>Время заявки</div>
            <div>application time</div>
            <div>raised matter</div>
          </div>
        </div>

        <div class="pt-3">
          <div class="w-[95%] h-[1px] bg-gray-300 mx-auto my-4"></div>
        </div>


        <div 
          v-if="statements" 
          v-for="(statement, index) in statements" 
          :key="index"
          @click="goToStatementProfile(statement)"
          class="pt-10 mx-24"
        > 
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[70px] h-[30px] bg-[#6388A8] rounded-[5px]"></div>

            <div v-if="statement.user?.first_name && statement.user?.last_name">
              {{ statement.user.first_name }} {{ statement.user.last_name }}
            </div>
            <div v-else>
              Неизвестно
            </div>

            <div>{{ statement.recipient }}</div>
            <div>{{ new Date(statement.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }) }}</div>
            <div>{{ statement.type?.type_name }}</div>

            <div v-if="statement.policeman && statement.policeman.first_name">
              {{ statement.policeman.first_name }} {{ statement.policeman.last_name }}
            </div>
            <div v-else>
              Неизвестно
            </div>
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

import { useStatementStore } from "../../stores/statement"

export default {
  name: "StatementPage",
  components: {
    Navbar,
  },
  setup() {
    const statements = ref(null);
    const route = useRoute();
    const router = useRouter();
    const rawDate = route.query.date;

    const selectedDate = ref(rawDate ? new Date(rawDate) : new Date());

    const formattedDate = computed(() =>
      selectedDate.value.toLocaleDateString('ru-RU', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      })
    );

    function goBack() {
      router.back();
    }

    function goToStatementProfile(statement) {
      debugger
      router.push({
        path: `/statement/${statement.id}`,
      });
    }

    const getStatementDate = async () => {
        try {
            const statementStore = useStatementStore();
            const statement_result = await statementStore.getAllStatement();
            statements.value = statement_result;
        } catch (err) {
            console.error("Ошибка при получении продуктов:", err);
            this.error = "Не удалось загрузить продукты";
        }
    };

    onMounted(() => {
      getStatementDate()
    });

    return {
      goBack,
      statements,
      goToStatementProfile,
      formattedDate,
    };
  },
};
</script>
