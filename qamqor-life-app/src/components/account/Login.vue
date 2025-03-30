<template>
  <div class="min-h-screen flex items-center justify-center">
    <div class="bg-white rounded-[25px] shadow-xl p-8 w-full max-w-md">
      <h2 class="text-2xl font-bold mb-6 text-center text-[#074841]">Войти в систему</h2>
      <form @submit.prevent="handleLogin">
        <div class="mb-4">
          <label class="block text-gray-700 mb-2" for="email">Имя</label>
          <input
            type="text"
            id="username"
            v-model="username"
            placeholder="Введите имя"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#074841]"
          />
        </div>
        <div class="mb-6">
          <label class="block text-gray-700 mb-2" for="password">Пароль</label>
          <input
            type="password"
            id="password"
            v-model="password"
            placeholder="Введите пароль"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#074841]"
          />
        </div>
        <div class="flex items-center justify-end mb-6">
          <a href="#" class="text-sm text-[#6388A8] hover:underline">Забыли пароль?</a>
        </div>
        <span v-if="error" class="block mt-4 text-red-500 pb-6 text-center">{{ error }}</span>
        <button type="submit" class="w-full bg-[#308e85] text-white py-2 rounded-[25px] hover:bg-[#074841] transition">
          Войти
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../../stores/auth'

export default {
  name: "Login",
  setup() {
    const username = ref('')
    const password = ref('')
    const error = ref("");

    const route = useRoute();
    const router = useRouter();

    const handleLogin = async () => {
        try {
            const authStore = useAuthStore();
            const result = await authStore.login(username.value, password.value);
            if (result.error) {
              error.value = result.error;
              return;
            }
            router.push({ name: "HomePage" });
        } catch (err) {
            console.error("Ошибка при получении продуктов:", err);
            this.error = "Не удалось загрузить продукты";
        }
    };

    return {
      handleLogin,
      error,
      username,
      password,
    };
  },
};
</script>
