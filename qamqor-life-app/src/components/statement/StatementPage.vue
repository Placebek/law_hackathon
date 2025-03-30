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
              Назначить исполнителя
            </button>
          </div>
        </div>

        <div v-if="isModalOpen">
          <AppointAnExecuter @close="closeModal" />
        </div>

        <div v-if="statement"  class="mt-8 bg-white text-[#005047] p-8 rounded-2xl shadow-sm w-[98%] mx-auto h-full" style="box-shadow: 0 4px 10px #A14200">
          <div class="flex justify-end">
            <p class="text-base mt-4 leading-8">
              <span class="font-semibold">Начальнику отдела полиции</span> №557<br>
              <span class="font-semibold">Управления полиции города</span> Караганды<br>
              <div v-if="!statement.anonymous || statement.anonymous === false">
                <span class="font-semibold">ИИН:</span> {{ statement.user.uin }}<br>
                <span class="font-semibold">Дата рождения:</span> {{ statement.user.birth_day }}<br>
                <span class="font-semibold">Телефон номера:</span> {{ statement.user.phone_number }}<br>
                <span class="font-semibold">Электронная почта:</span> {{ statement.user.email }}<br>
                <span class="font-semibold">Адрес проживания:</span> Караганда, Строителей 3/2<br>
              </div>
              <div v-else>
                <span class="font-semibold">ИИН:</span> Неизвестно<br>
                <span class="font-semibold">Дата рождения:</span> Неизвестно<br>
                <span class="font-semibold">Телефон номера:</span> Неизвестно<br>
                <span class="font-semibold">Электронная почта:</span> Неизвестно<br>
                <span class="font-semibold">Адрес проживания:</span> Неизвестно<br>
              </div>
            </p>
          </div>
          <div class="flex justify-center pt-20">
            <p class="font-semibold text-[25px]">
              Заявление
            </p>
          </div>
          <div class="px-10 leading-8">
            <div class="pt-4 indent-10">
              <div v-if="!statement.anonymous || statement.anonymous === false">
                <p>
                  Я, {{ statement.user.first_name}} {{ statement.user.last_name}}, проживающий по адресу: г. Караганда, ул. Сторителей 3/2, д. 45, кв. 12, паспорт №12345678, выдан 15.05.2015 г., настоящим сообщаю о факте шантажа в мой адрес.
                </p>
              </div>    
              <div v-else>
                Я бы хотел(-а) скрыть свой личные данные
              </div>
              <p>
                Обстоятельства дела:
                {{ statement.text }}<br>
              </p>
              <div class="indent-10">
                <p>
                  Записи с видеокамер:
                  Ссылки на Telegram-канал.
                </p>
              </div>
            </div>

            <div class="indent-10 pt-10">
              <p>
                К заявлению прилагаются копия полученного сообщения и копия документа, удостоверяющего личность.
              </p>
              <div v-if="statement.policeman">
                <p>
                  Заявление было принято сотрудником полиции 
                  {{ statement.policeman.first_name }} {{ statement.policeman.last_name }},
                  контактные данные: телефон {{ statement.policeman.phone_number }}, e-mail {{ statement.policeman.email }}.
                </p>
              </div>
            </div>

            <div v-if="statement.created_at" class="indent-10 pt-5">
              <p>
                Дата подачи заявления: {{ statement.created_at }}
              </p>
              <p class="font-semibold">
                Подпись: _________________________________________
              </p>
            </div>
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
import AppointAnExecuter from "../add/AppointAnExecuter.vue";


export default {
  name: "StatementPage",
  components: {
    Navbar,
    AppointAnExecuter,
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

    const isModalOpen = ref(false);

    const openModal = () => {
      isModalOpen.value = true;
    };

    const closeModal = () => {
      isModalOpen.value = false;
    };

    const getStatementDate = async () => {
        try {
          const statementStore = useStatementStore();
          const statement_result = await statementStore.getStatementByID(statementId);

          if (statement_result.user && statement_result.user.birth_day) {
            const birthDate = new Date(statement_result.user.birth_day);
            const birthDay = ("0" + birthDate.getDate()).slice(-2);
            const birthMonth = ("0" + (birthDate.getMonth() + 1)).slice(-2);
            const birthYear = birthDate.getFullYear();
            statement_result.user.birth_day = `${birthDay}.${birthMonth}.${birthYear}`;
          }

          if (statement_result.created_at) {
            const createdDate = new Date(statement_result.created_at);
            const createdDay = ("0" + createdDate.getDate()).slice(-2);
            const createdMonth = ("0" + (createdDate.getMonth() + 1)).slice(-2);
            const createdYear = createdDate.getFullYear();
            statement_result.created_at = `${createdDay}.${createdMonth}.${createdYear}`;
          }

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
      statement,
      openModal,
      closeModal,
      isModalOpen,
    };
  },
};
</script>
