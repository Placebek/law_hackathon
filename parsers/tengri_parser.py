from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException
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
        
        news_count = 0  # Счетчик новостей
        max_news = 15  # Лимит новостей

        while news_count < max_news:
            try:
                rubrics = self.driver.find_elements(By.CSS_SELECTOR, "div.content.rubric")
                for rubric in rubrics:
                    inline_block = rubric.find_elements(By.CSS_SELECTOR, "div.content_main")
                    if inline_block:
                        news_containers = inline_block[0].find_elements(By.CSS_SELECTOR, "div.content_main_item")
                        for container in news_containers:
                            if news_count >= max_news:
                                break
                            try:
                                news_link = container.find_element(By.CSS_SELECTOR, "a")
                                news_href = news_link.get_attribute('href')
                                
                                self.driver.execute_script(f"window.open('{news_href}', '_blank');")
                                self.driver.switch_to.window(self.driver.window_handles[-1])

                                h1_element = WebDriverWait(self.driver, 10).until(
                                    EC.presence_of_element_located((By.CSS_SELECTOR, "h1.head-single"))
                                )
                                news_header_text = h1_element.text if h1_element else ""

                                news_date_element = self.driver.find_elements(By.XPATH, "/html/head/meta[@property='article:published_time']")
                                news_date = news_date_element[0].get_attribute('content') if news_date_element else ""

                                news_image_element = self.driver.find_elements(By.XPATH, "/html/body/div[2]/main/section[1]/div/div[1]/div[2]/picture/img")
                                news_image = news_image_element[0].get_attribute('src') if news_image_element else None

                                news_text = ""
                                news_text_blocks = self.driver.find_elements(By.CSS_SELECTOR, "div.content_main_inner div.content_main_text")
                                if news_text_blocks:
                                    paragraphs = news_text_blocks[0].find_elements(By.TAG_NAME, "p")
                                    news_text = " ".join(p.text for p in paragraphs if p.text)
                                
                                news_dict = {
                                    "header": news_header_text,
                                    "text": news_text,
                                    "date": news_date,
                                    "image": news_image,
                                }
                                
                                print(f"Добавлена новость: {news_header_text}")
                                self.all_news.append(news_dict)
                                news_count += 1
                            
                            except (NoSuchElementException, TimeoutException) as e:
                                print(f"Ошибка при обработке новости: {e}")
                            
                            finally:
                                self.driver.close()
                                self.driver.switch_to.window(self.driver.window_handles[0])

                # Проверяем кнопку "Следующая страница"
                if news_count < max_news:
                    try:
                        next_button = WebDriverWait(self.driver, 5).until(
                            EC.element_to_be_clickable((By.CSS_SELECTOR, "ul.pagination > li:last-child a"))
                        )
                        next_button.click()
                        time.sleep(2)  # Небольшая задержка для загрузки новой страницы
                    except TimeoutException:
                        print("Достигнута последняя страница.")
                        break
                else:
                    break
            except Exception as e:
                print(f"Ошибка при парсинге: {e}")
                break
        
        self.add_all_to_db()

    def add_all_to_db(self):
        with sync_session_factory() as session:
            try:
                news_objects = [
                    News(
                        # header=news["header"],
                        text=news["text"],
                        date=news["date"],
                        image=news["image"]
                    ) for news in self.all_news
                ]
                session.add_all(news_objects)
                session.commit()
                print(f"✅ В базу добавлено {len(news_objects)} новостей")
            except Exception as e:
                session.rollback()
                print(f"❗ Ошибка при сохранении новостей: {e}")

    def close_browser(self):
        if self.driver:
            self.driver.quit()

if __name__ == "__main__":
    parser = TengriNewsParser()
    parser.start_browser()
    parser.parse()
    parser.close_browser()
