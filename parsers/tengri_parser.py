from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
import time, sys, os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from model.model import News
from database.db import sync_session_factory

class TengriNewsParser:
    def __init__(self):
        self.driver = None

        self.all_news = []

    def start_browser(self):
        self.driver = webdriver.Chrome()

    def parse(self, url="https://tengrinews.kz/crime/"):
        self.driver.get(url)

        pages = self.driver.find_elements(By.CSS_SELECTOR, "ul.pagination > li")

        while True:
            pages = self.driver.find_elements(By.CSS_SELECTOR, "ul.pagination > li")  # Получаем список элементов пагинации
            last_page = pages[-1]  # Берем последний <li>

            try:
                next_button = last_page.find_element(By.TAG_NAME, "a")  # Ищем <a> внутри последнего <li>

                rubrics = self.driver.find_elements(By.CSS_SELECTOR, "div.content.rubric")

                for rubric in rubrics:
                    inline_block = rubric.find_elements(By.CSS_SELECTOR, "div.content_main")
                    if inline_block != []:
                        news_containers = inline_block[0].find_elements(By.CSS_SELECTOR, "div.content_main_item")
                        for container in news_containers:
                            news_link = container.find_element(By.CSS_SELECTOR, "a")

                            news_href = news_link.get_attribute('href')

                            self.driver.execute_script(f"window.open('{news_href}', '_blank');")

                            self.driver.switch_to.window(self.driver.window_handles[-1])

                            h1_element = WebDriverWait(self.driver, 10).until(
                                lambda driver: driver.find_element(By.CSS_SELECTOR, "h1.head-single")
                            )

                            news_header_text = h1_element.text

                            news_date = self.driver.find_element(By.XPATH, "/html/body/div[2]/main/section[1]/ol/li[3]")

                            news_image_element = self.driver.find_elements(By.XPATH, "/html/body/div[2]/main/section[1]/div/div[1]/div[2]/picture/img")
                            news_image = None
                            if news_image_element != []:
                                news_image = news_image_element[0].get_attribute('src')

                            news_text = ""

                            news_text_blocks = self.driver.find_elements(By.CSS_SELECTOR, "div.content_main_inner")
                            if news_text_blocks:
                                news_text_block = news_text_blocks[0].find_element(By.CSS_SELECTOR, "div.content_main_text")
                                paragraphs = news_text_block.find_elements(By.TAG_NAME, "p")

                                news_text = " ".join(p.text for p in paragraphs)

                            news_date_object = self.driver.find_elements(By.XPATH, "/html/head/meta[9]")

                            if news_date_object != []:
                                news_date = news_date_object[0].get_attribute('content')

                            news_dict = {
                                "header": news_header_text,
                                "text": news_text,
                                "date": news_date,
                                "image": news_image,
                            }

                            print("ASDADASDASDASDDDS: ", news_date)

                            self.all_news.append(news_dict)

                            self.driver.close()
                            self.driver.switch_to.window(self.driver.window_handles[0])
                            break
                        break
                    break
                break

                next_button.click()
            except NoSuchElementException as e:
                break

        self.add_all_to_db(self.all_news)

        print("SLLLLLLLLLLLLLLLL: ", len(self.all_news))

    def add_all_to_db(self, all_news):
        with sync_session_factory() as session:
            try:
                news_objects = [
                    News(
                        text=news["text"],
                        date=news["date"],
                        image=news["image"],
                    )
                    for news in self.all_news
                ]
                session.add_all(news_objects)
                session.commit()

                print(f"✅ В базу добавлено {len(news_objects)} новостей")
            except Exception as e:
                session.rollback()
                print(f"❗ Ошибка при сохранении новостей: {e}")

    def close_browser(self):
        self.driver.quit()

if __name__ == "__main__":
    parser = TengriNewsParser()
    parser.start_browser()
    parser.parse()
    parser.close_browser()
