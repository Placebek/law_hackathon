<template>
  <div class="bg-white rounded-[25px] shadow-xl p-6 w-full max-w-2xl mx-auto text-gray-700" style="box-shadow: 0 4px 10px #FFFFFF">
    <div class="flex items-center justify-between mb-4">
      <div>
        <h2 class="text-xl text-[#377973] font-bold">Статистика</h2>
        <p class="text-sm text-gray-400">Поданные заявления за день</p>
      </div>
      <div class="text-[#BA6F2E] px-3 py-1 text-sm rounded-full flex items-center gap-2">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M8 7V3m8 4V3m-9 4h10a2 2 0 012 2v9a2 2 0 01-2 2H7a2 2 0 01-2-2V9a2 2 0 012-2z" />
        </svg>
        <h2 class="text-md">{{ formattedDate }}</h2>
      </div>
    </div>

    <apexchart
      type="area"
      height="250"
      :options="chartOptions"
      :series="series"
    />

    <div class="mt-4 flex gap-6">
      <div class="flex items-center gap-2">
        <span class="w-3 h-3 inline-block bg-[#E1B89A] rounded-full"></span>
        <span class="text-sm text-gray-600">Принятые заявления</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="w-3 h-3 inline-block bg-[#FEB27D] rounded-full"></span>
        <span class="text-sm text-gray-600">Заявления в отработке</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="w-3 h-3 inline-block bg-[#78BFB8] rounded-full"></span>
        <span class="text-sm text-gray-600">Ожидают проверки</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="w-3 h-3 inline-block bg-[#2F8178] rounded-full"></span>
        <span class="text-sm text-gray-600">Завершённые дела</span>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from "vue";
import VueApexCharts from "vue3-apexcharts";

export default {
  name: "StatisticFrame",
  components: {
    apexchart: VueApexCharts,
  },
  props: {
    selectedDate: {
      type: Date,
      required: true,
    },
  },
  setup(props) {
    const formattedDate = computed(() =>
      props.selectedDate.toLocaleDateString("ru-RU", {
        day: "numeric",
        month: "long",
        year: "numeric",
      })
    );

    const series = ref([
      {
        name: "Принятые заявления",
        data: [0, 12, 2, 3],
      },
      {
        name: "Заявления в отработке",
        data: [0, 9, 6, 2],
      },
      {
        name: "Ожидают проверки",
        data: [0, 8, 5, 9],
      },
      {
        name: "Завершённые дела",
        data: [0, 21, 4, 3],
      },
    ]);

    const chartOptions = ref({
      chart: {
        toolbar: { show: false },
        sparkline: { enabled: false },
      },
      stroke: {
        curve: "smooth",
        width: 3,
      },
      fill: {
        type: "gradient",
        gradient: {
          shadeIntensity: 1,
          inverseColors: false,
          opacityFrom: 0.4,
          opacityTo: 0,
          stops: [0, 90, 100],
        },
      },
      colors: ["#E1B89A", "#FEB27D", "#78BFB8", "#2F8178"],
      xaxis: {
        categories: ["Утро", "День", "Вечер", "Ночь"],
        labels: {
          style: {
            colors: "#9CA3AF",
          },
        },
      },
      yaxis: {
        min: 0,
        max: 30,
        labels: {
          style: {
            colors: "#9CA3AF",
          },
        },
      },
      legend: {
        show: false,
      },
    });

    return {
      series,
      chartOptions,
      formattedDate,
    };
  },
};
</script>
