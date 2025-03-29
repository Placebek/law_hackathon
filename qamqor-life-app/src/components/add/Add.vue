<template>
  <div class="bg-white p-8 rounded-2xl shadow-xl w-[70%] max-w-3xl mx-auto text-[#277D74]"
       style="height: 90vh; overflow-y: auto; position: relative;">

    <h2 class="text-2xl font-bold text-center mb-6">
      Добавить нового полицейского
    </h2>

    <form @submit.prevent="submitForm" class="space-y-4">
      <div class="grid grid-cols-12">
        <div class="col-span-9 grid grid-rows-3 gap-4 pe-4">
          <div class="">
            <label class="block text-[#15524C] mb-1">Имя</label>
            <input
              v-model="formData.firstName"
              type="text"
              placeholder="Введите имя"
              required
              class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
            />
          </div>
          <div>
            <label class="block text-[#15524C] mb-1">Отчество</label>
            <input
              v-model="formData.patronymic"
              type="text"
              placeholder="Введите отчество"
              required
              class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
            />
          </div>
          <div>
            <label class="block text-[#15524C] mb-1">Фамилия</label>
            <input
              v-model="formData.lastName"
              type="text"
              placeholder="Введите фамилию"
              required
              class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
            />
          </div>
        </div>

        <div class="col-span-3 overflow-hidden rounded-xl border border-gray-200 flex items-center justify-center bg-gray-100">
          <template v-if="formData.photo">
            <img :src="formData.photo" alt="Фото полицейского" class="w-full h-full object-cover" />
          </template>
          <template v-else>
            <label for="fileInput" class="cursor-pointer text-sm px-3 py-1 bg-[#277D74] text-white rounded hover:bg-blue-600 transition">
              Выберите файл
            </label>
            <input id="fileInput" type="file" @change="handleFileUpload" class="hidden" />
          </template>
        </div>

      
      </div>



      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-[#15524C] mb-1">Email</label>
          <input
            v-model="formData.email"
            type="email"
            placeholder="example@mail.com"
            required
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
          />
        </div>
        <div>
          <label class="block text-[#15524C] mb-1">Телефон</label>
          <input
            v-model="formData.phone"
            type="text"
            placeholder="+7 (___) ___-__-__"
            required
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
          />
        </div>
      </div>

      <div>
        <label class="block text-[#15524C] mb-1">День рождения</label>
        <input
          v-model="formData.birthDate"
          type="date"
          required
          class="w-full p-2 border rounded-lg focus:outline-none text-[#15524C] focus:ring-2 focus:ring-[#15524C]"
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-[#15524C] mb-1">Звание</label>
          <input
            v-model="formData.rank"
            type="text"
            placeholder="Например, Старший полковник"
            required
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
          />
        </div>
        <div>
          <label class="block text-[#15524C] mb-1">Станция</label>
          <input
            v-model="formData.station"
            type="text"
            placeholder="Название отделения"
            required
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
          />
        </div>
      </div>

      <div>
        <label class="block text-[#15524C] mb-1">Резюме</label>
        <textarea
          v-model="formData.resume"
          placeholder="Введите краткую информацию о полицейском"
          class="w-full h-[300px] p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#15524C]"
        ></textarea>
      </div>

      <div class="flex justify-end space-x-4">
        <button
          type="button"
          @click="closeModal"
          class="px-4 py-2 border rounded-lg text-[#277D74] hover:bg-gray-100 transition"
        >
          Отмена
        </button>
        <button
          type="submit"
          class="px-4 py-2 bg-[#277D74] text-white rounded-lg hover:bg-[#557A95] transition"
        >
          Сохранить
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const emit = defineEmits(['close', 'submit'])

const formData = ref({
  firstName: '',
  patronymic: '',
  lastName: '',
  email: '',
  phone: '',
  birthDate: '',
  photo: '',
  rank: '',
  station: '',
  resume: '',
})

function handleFileUpload(event) {
  const file = event.target.files[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = () => {
      formData.value.photo = reader.result
    }
    reader.readAsDataURL(file)
  }
}

function closeModal() {
  emit('close')
}

function submitForm() {
  console.log('Данные нового сотрудника:', formData.value)
  emit('submit', formData.value)
  closeModal()
}
</script>
