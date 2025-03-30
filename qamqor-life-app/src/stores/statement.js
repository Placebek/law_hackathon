import { defineStore } from 'pinia';
import axios from 'axios';

export const useStatementStore = defineStore('statement', {
  state: () => ({
  }),

  actions: {
    async getAllStatement() {
      try {
        const response = await axios.get(
          `http://172.20.10.2:8000/v1/get-all-statements`, 
        );
        return response.data;

      } catch (error) {
        if (error.response) {
          this.error = error.response.data.message || 'Ошибка при авторизации';
        } else {
          this.error = 'Произошла ошибка, повторите позднее';
        }
        return { success: false, error: this.error };
      }
    },
    async getStatementByID(statement_id) {
      try {
          const response = await axios.get(
              `http://172.20.10.2:8000/v1/statement/${statement_id}`, 
          );
          return response.data;

      } catch (error) {
          if (error.response) {
              this.error = error.response.data.message || 'Ошибка при авторизации';
          } else {
              this.error = 'Произошла ошибка, повторите позднее';
          }
          return { success: false, error: this.error };
      }
    },
  },

  persist: true, 
});
