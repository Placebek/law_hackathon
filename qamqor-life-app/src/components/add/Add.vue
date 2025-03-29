<template>
  <div class="bg-white p-8 rounded-2xl shadow-xl w-full max-w-3xl mx-auto text-[#6388A8]" style="height: 90vh; overflow-y: auto;">
    <h2 class="text-2xl font-bold text-center mb-6 text-[#6388A8]">
      Добавить нового полицейского
    </h2>
    <form @submit.prevent="submitForm" class="space-y-4">
      <div class="grid grid-cols-3 gap-4">
        <div>
          <label class="block text-gray-700 mb-1">Имя</label>
          <input
            v-model="formData.firstName"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="Введите имя"
            required
          />
        </div>
        <div>
          <label class="block text-gray-700 mb-1">Отчество</label>
          <input
            v-model="formData.patronymic"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="Введите отчество"
            required
          />
        </div>
        <div>
          <label class="block text-gray-700 mb-1">Фамилия</label>
          <input
            v-model="formData.lastName"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="Введите фамилию"
            required
          />
        </div>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-gray-700 mb-1">Email</label>
          <input
            v-model="formData.email"
            type="email"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="example@mail.com"
            required
          />
        </div>
        <div>
          <label class="block text-gray-700 mb-1">Телефон</label>
          <input
            v-model="formData.phone"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="+7 (___) ___-__-__"
            required
          />
        </div>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-gray-700 mb-1">День рождения</label>
          <input
            v-model="formData.birthDate"
            type="date"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            required
          />
        </div>
      </div>
      
      <div class="flex flex-col space-y-2">
        <label class="text-gray-700">Фото</label>
        <input
          type="file"
          @change="handleFileUpload"
          class="w-full p-2 border rounded-lg"
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-gray-700 mb-1">Звание</label>
          <input
            v-model="formData.rank"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="Например, Старший полковник"
            required
          />
        </div>
        <div>
          <label class="block text-gray-700 mb-1">Станция</label>
          <input
            v-model="formData.station"
            type="text"
            class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
            placeholder="Название отделения"
            required
          />
        </div>
      </div>

      <div>
        <label class="block text-gray-700 mb-1">Резюме</label>
        <textarea
          v-model="formData.resume"
          class="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#6388A8]"
          placeholder="Введите краткую информацию о полицейском"
        ></textarea>
      </div>

      <div class="flex justify-end space-x-4">
        <button
          type="button"
          @click="closeModal"
          class="px-4 py-2 border rounded-lg text-[#6388A8] hover:bg-gray-100 transition"
        >
          Отмена
        </button>
        <button
          type="submit"
          class="px-4 py-2 bg-[#6388A8] text-white rounded-lg hover:bg-[#557A95] transition"
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
  console.log('Данные нового полицейского:', formData.value)
  emit('submit', formData.value)
  closeModal()
}
</script>
