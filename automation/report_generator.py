"""
report_generator.py
Purpose: Generate a text-summary PDF from database KPIs, then merge it 
with the Power BI dashboard PDF into one final report.
"""
import sys
import os
from datetime import datetime
from fpdf import FPDF
from pypdf import PdfWriter, PdfReader
# Allow importing from src/ folder
sys.path.append(os.path.join(os.path.dirname(__file__),'..', 'src'))
from database import get_engine, fetch_data

def create_summary_pdf(data,output_path):
    """
    Creates a text-based summary PDF with KPIs and key tables.
    """
    pdf=FPDF()
    pdf.add_page()
    # ---- Header ----
    pdf.set_font("Arial","B",20)
    pdf.cell(0,12,"Sales Report",ln=True,align="C")
    #----Date ---
    pdf.set_font("Arial", "", 11)
    today = datetime.now().strftime("%d %B %Y")
    pdf.cell(0, 8, f"Generated on: {today}", ln=True, align="C")
    pdf.ln(8)
    #---- Creation name
    pdf.set_font("Arial","",9)
    pdf.cell(0,7,f"Created By - {str(input('enter your name'))}",ln=True,align='R')

    #---- KPI --------
    pdf.set_font("Arial","B",14)
    pdf.cell(0,10,"Overall Summary",ln=True)
    pdf.set_font("Arial","",11)

    overall=data.get('overall_summary')
    if overall is not None and not overall.empty:
        row = overall.iloc[0]
        pdf.cell(0, 8, f"Total Revenue: ${row.get('total_revenue', 0):,.2f}", ln=True)
        pdf.cell(0, 8, f"Total Profit: ${row.get('total_profit', 0):,.2f}", ln=True)
        pdf.cell(0, 8, f"Total Orders: {row.get('total_orders', 0):,}", ln=True)
        pdf.cell(0, 8, f"Avg Order Value: ${row.get('avg_order_value', 0):,.2f}", ln=True)
        pdf.cell(0, 8, f"Avg Rating: {row.get('avg_rating', 0):.2f}", ln=True)
    else:
        pdf.cell(0, 8, "No summary data available.", ln=True)

    pdf.ln(6)

    # ---- City Performance Table ----
    pdf.set_font("Arial", "B", 14)
    pdf.cell(0, 10, "City Performance", ln=True)
    pdf.set_font("Arial", "B", 10)

    city_df = data.get('city_performance')
    if city_df is not None and not city_df.empty:
        # Table header
        pdf.cell(50, 8, "City", border=1)
        pdf.cell(50, 8, "Revenue", border=1)
        pdf.cell(50, 8, "Profit", border=1)
        pdf.ln()

        pdf.set_font("Arial", "", 10)
        for _, r in city_df.iterrows():
            pdf.cell(50, 8, str(r.get('city', '')), border=1)
            pdf.cell(50, 8, f"${r.get('total_revenue', 0):,.0f}", border=1)
            pdf.cell(50, 8, f"${r.get('total_profit', 0):,.0f}", border=1)
            pdf.ln()
    else:
        pdf.set_font("Arial", "", 10)
        pdf.cell(0, 8, "No city data available.", ln=True)

    pdf.ln(6)  
    # ---- Footer Note ----
    pdf.set_font("Arial", "I", 9)
    pdf.cell(0, 8, "Detailed dashboard visuals are attached in the following pages.", ln=True)

    pdf.output(output_path)
    print(f"Summary PDF created: {output_path}")


def merge_pdfs(summary_pdf_path, dashboard_pdf_path, final_output_path):
    """
    Merges the summary PDF with the Power BI dashboard PDF.
    """
    writer = PdfWriter()

    try:
        # Add summary pages
        summary_reader = PdfReader(summary_pdf_path)
        for page in summary_reader.pages:
            writer.add_page(page)

        # Add dashboard pages
        dashboard_reader = PdfReader(dashboard_pdf_path)
        for page in dashboard_reader.pages:
            writer.add_page(page)

        with open(final_output_path, "wb") as f:
            writer.write(f)

        print(f"Final merged report created: {final_output_path}")

    except Exception as e:
        print(f"Failed to merge PDFs: {e}")


def generate_report():
    """
    Full pipeline: fetch data -> create summary -> merge with dashboard PDF.
    """
    #------ Connect to DB and fetch data
    engine = get_engine(
        user="postgres",
        password="l12345",
        host="localhost",
        port="5433",
        dbname="SQL"
    )
    data = fetch_data(engine)

    if data is None:
        print("Could not fetch data. Aborting report generation.")
        return

    # ---- Paths
    base_dir = os.path.dirname(os.path.dirname(__file__))  # project root
    date_str = datetime.now().strftime("%Y-%m-%d")

    summary_pdf_path = os.path.join(base_dir, "reports", "generated", "temp_summary.pdf")
    dashboard_pdf_path = os.path.join(base_dir, "powerbi", "screenshots", "Dashboards_Screenshot.pdf")
    final_output_path = os.path.join(base_dir, "reports", "generated", f"sales_report_{date_str}.pdf")

    # -----Create summary PDF
    create_summary_pdf(data, summary_pdf_path)

    # ---- Merge with dashboard PDF
    merge_pdfs(summary_pdf_path, dashboard_pdf_path, final_output_path)

    # ----- Clean up temp file
    if os.path.exists(summary_pdf_path):
        os.remove(summary_pdf_path)

    return final_output_path


if __name__ == "__main__":
    generate_report()
