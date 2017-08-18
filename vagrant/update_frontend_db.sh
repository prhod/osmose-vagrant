
psql -h localhost -U osmose -d osmose_frontend -c "INSERT INTO dynpoi_stats (SELECT dynpoi_class.source, dynpoi_class.class, now(), count(marker.source) FROM dynpoi_class LEFT JOIN marker ON dynpoi_class.source=marker.source AND dynpoi_class.class=marker.class GROUP BY dynpoi_class.source, dynpoi_class.class);"

psql -h localhost -U osmose -d osmose_frontend -c "UPDATE dynpoi_item SET levels = (SELECT array_agg(level)
              FROM (SELECT level FROM dynpoi_class
                    WHERE dynpoi_class.item = dynpoi_item.item
                    GROUP BY level
                    ORDER BY level
                   ) AS a
             );"

psql -h localhost -U osmose -d osmose_frontend -c "UPDATE dynpoi_item SET number = (SELECT array_agg(n)
              FROM (SELECT count(*) AS n FROM marker
                    JOIN dynpoi_class ON dynpoi_class.source = marker.source AND
                                         dynpoi_class.class = marker.class
                    WHERE dynpoi_class.item = dynpoi_item.item
                    GROUP BY level
                    ORDER BY level
                   ) AS a
             );"

psql -h localhost -U osmose -d osmose_frontend -c "UPDATE dynpoi_item SET tags = (SELECT array_agg(tag)
              FROM (
                SELECT
                    tag
                FROM
                    (SELECT unnest(tags) AS tag, item FROM dynpoi_class WHERE dynpoi_class.item = dynpoi_item.item) AS dynpoi_class
                WHERE
                    tag != ''
                GROUP BY tag
                ORDER BY tag
             ) AS a
             );"
