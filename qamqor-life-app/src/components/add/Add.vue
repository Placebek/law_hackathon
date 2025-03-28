<template>
  <div class="bg-white p-8 rounded-lg w-full max-w-md">
    <h2 class="text-xl font-bold mb-4">Анкета нового рабочего</h2>
    <form @submit.prevent="submitForm">
      <div class="mb-4">
        <label class="block text-gray-700 mb-1">Имя</label>
        <input
          v-model="formData.name"
          type="text"
          class="w-full p-2 border rounded"
          placeholder="Введите имя"
          required
        />
      </div>
      <div class="mb-4">
        <label class="block text-gray-700 mb-1">Должность</label>
        <input
          v-model="formData.position"
          type="text"
          class="w-full p-2 border rounded"
          placeholder="Введите должность"
          required
        />
      </div>
      <div class="flex justify-end">
        <button
          type="button"
          @click="closeModal"
          class="mr-2 px-4 py-2 border rounded text-black"
        >
          Отмена
        </button>
        <button
          type="submit"
          class="px-4 py-2 bg-blue-500 text-white rounded"
        >
          Сохранить
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  onSubmit: {
    type: Function,
    required: true,
  }
})

const emit = defineEmits(['close'])

const formData = ref({
  name: '',
  position: '',
})

function closeModal() {
  emit('close')
}

function submitForm() {
  console.log('Данные формы в Add:', formData.value)
  props.onSubmit(formData.value)
  closeModal()
}
</script>
