<template>
  <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 w-full">
    <div class="bg-white flex flex-col justify-center p-6 rounded-[25px] shadow-lg w-[20%] h-[30%] relative text-center">
      <h2 class="text-xl font-semibold mb-4">Вы уверены?</h2>

      <div class="mt-4">
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
          Да
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  emits: ["close"],
  methods: {
    closeModal() {
      this.$emit("close");
    },
  },
};
</script>
